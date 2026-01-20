import Foundation

class BackupService {
    
    private let fileManager = FileManager.default
    private let dbPath: URL
    private let backupsDirectory: URL
    
    init() {
        // This will crash if the database path cannot be determined, which is intentional.
        // If the database doesn't exist, the app can't function.
        let appSupportURL = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let rocafeDir = appSupportURL.appendingPathComponent("rocafe")
        self.dbPath = rocafeDir.appendingPathComponent("rocafe.sqlite")
        self.backupsDirectory = rocafeDir.appendingPathComponent("Backups")
        
        // Create the backups directory if it doesn't exist
        try? fileManager.createDirectory(at: backupsDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Creates a timestamped backup of the database file.
    func performBackup() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let backupFileName = "rocafe-backup-\(timestamp).sqlite"
        let backupURL = backupsDirectory.appendingPathComponent(backupFileName)
        
        // Ensure the source file exists
        guard fileManager.fileExists(atPath: dbPath.path) else {
            throw NSError(domain: "BackupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Database file not found."])
        }
        
        try fileManager.copyItem(at: dbPath, to: backupURL)
        print("Backup created at: \(backupURL.path)")
        
        pruneOldBackups()
    }
    
    /// Restores the database from a given backup file.
    /// This is a destructive operation.
    func restoreFromBackup(fileURL: URL) throws {
        // Ensure the backup file exists
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "BackupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Backup file not found."])
        }
        
        // This is a destructive operation. In a real app, you would
        // close the database connection before performing this.
        try fileManager.replaceItem(at: dbPath, withItemAt: fileURL, backupItemName: nil, options: [])
        
        print("Database restored from: \(fileURL.path)")
        // The app should probably be restarted after this.
    }
    
    /// Deletes old backups, keeping the last 30.
    private func pruneOldBackups() {
        do {
            let backupFiles = try fileManager.contentsOfDirectory(at: backupsDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            // Sort by creation date, oldest first
            let sortedFiles = backupFiles.sorted { (url1, url2) -> Bool in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 < date2
            }
            
            let filesToDelete = sortedFiles.dropLast(30) // Keep the 30 newest
            
            for file in filesToDelete {
                try fileManager.removeItem(at: file)
                print("Deleted old backup: \(file.lastPathComponent)")
            }
            
        } catch {
            print("Error pruning old backups: \(error)")
        }
    }
}
