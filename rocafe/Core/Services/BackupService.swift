import Foundation
import GRDB

enum BackupServiceError: Error, LocalizedError {
    case databaseNotFound
    case backupDirectoryUnwritable
    case backupFailed(Error)
    case restoreFailed(Error)
    case backupFileInvalid(path: String)
    case backupFileNotFound(path: String)
    case preRestoreBackupFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .databaseNotFound:
            return "O arquivo do banco de dados principal não foi encontrado."
        case .backupDirectoryUnwritable:
            return "O diretório de backups não pôde ser criado ou acessado."
        case .backupFailed(let error):
            return "A criação do backup falhou: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "A restauração do banco de dados falhou: \(error.localizedDescription)"
        case .backupFileInvalid(let path):
            return "O arquivo de backup em '\(path)' está corrompido ou não é um banco de dados válido."
        case .backupFileNotFound(let path):
            return "O arquivo de backup em '\(path)' não foi encontrado."
        case .preRestoreBackupFailed(let error):
            return "Falha ao criar o backup de emergência do banco de dados atual antes da restauração: \(error.localizedDescription)"
        }
    }
}


class BackupService {
    
    private let fileManager = FileManager.default
    private let dbPath: URL
    private let backupsDirectory: URL
    
    private let automaticBackupRetentionCount = 14 // Keep the last 14 automatic backups
    
    init() throws {
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let rocafeDir = appSupportURL.appendingPathComponent("rocafe")
        self.dbPath = rocafeDir.appendingPathComponent("rocafe.sqlite")
        self.backupsDirectory = rocafeDir.appendingPathComponent("Backups")
        
        do {
            try fileManager.createDirectory(at: backupsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw BackupServiceError.backupDirectoryUnwritable
        }
    }
    
    /// Creates a timestamped backup in the default backup directory and prunes old ones.
    func performAutomaticBackup() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let backupFileName = "rocafe-auto-backup-\(timestamp).sqlite"
        let backupURL = backupsDirectory.appendingPathComponent(backupFileName)
        
        do {
            try performManualBackup(to: backupURL)
            print("Automatic backup created at: \(backupURL.path)")
            try pruneOldBackups()
        } catch {
            throw BackupServiceError.backupFailed(error)
        }
    }
    
    /// Creates a backup of the database to a specific user-chosen URL.
    func performManualBackup(to destinationURL: URL) throws {
        guard fileManager.fileExists(atPath: dbPath.path) else {
            throw BackupServiceError.databaseNotFound
        }
        
        // Use a temporary file to handle cases where destination is on a different volume
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.copyItem(at: dbPath, to: tempURL)
        try fileManager.moveItem(at: tempURL, to: destinationURL)
    }
    
    /// Restores the database from a given backup file using a safe process.
    func restore(from backupURL: URL) throws {
        guard fileManager.fileExists(atPath: backupURL.path) else {
            throw BackupServiceError.backupFileNotFound(path: backupURL.path)
        }
        
        try verifyBackupIntegrity(at: backupURL)
        
        // 1. Create a pre-restore backup of the current DB for safety
        let preRestoreBackupURL = backupsDirectory.appendingPathComponent("rocafe-pre-restore-\(Date().timeIntervalSince1970).sqlite")
        do {
            try fileManager.moveItem(at: dbPath, to: preRestoreBackupURL)
        } catch {
            throw BackupServiceError.preRestoreBackupFailed(error)
        }
        
        // 2. Copy the backup file to the main DB path
        do {
            try fileManager.copyItem(at: backupURL, to: dbPath)
            print("Database restored from: \(backupURL.path)")
            // The app MUST be restarted after this operation.
        } catch {
            // 3. If restore fails, try to roll back by restoring the pre-restore backup.
            print("Restore failed. Attempting to roll back...")
            try? fileManager.moveItem(at: preRestoreBackupURL, to: dbPath)
            throw BackupServiceError.restoreFailed(error)
        }
    }
    
    /// Checks if a given SQLite file is a valid and uncorrupted database.
    private func verifyBackupIntegrity(at backupURL: URL) throws {
        do {
            let dbQueue = try DatabaseQueue(path: backupURL.path)
            let integrity = try String.fetchOne(dbQueue, sql: "PRAGMA integrity_check(1)")
            if integrity != "ok" {
                throw BackupServiceError.backupFileInvalid(path: backupURL.path)
            }
        } catch {
            throw BackupServiceError.backupFileInvalid(path: backupURL.path)
        }
    }
    
    /// Deletes old backups, keeping the number defined in `automaticBackupRetentionCount`.
    private func pruneOldBackups() throws {
        let backupFiles = try fileManager.contentsOfDirectory(at: backupsDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        
        // Only consider automatic backups for pruning
        let autoBackupFiles = backupFiles.filter { $0.lastPathComponent.contains("rocafe-auto-backup") }
        
        if autoBackupFiles.count <= automaticBackupRetentionCount {
            return // No need to prune
        }
        
        let sortedFiles = autoBackupFiles.sorted { (url1, url2) -> Bool in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            return date1 < date2
        }
        
        let filesToDelete = sortedFiles.dropLast(automaticBackupRetentionCount)
        
        for file in filesToDelete {
            try fileManager.removeItem(at: file)
            print("Deleted old backup: \(file.lastPathComponent)")
        }
    }
}
