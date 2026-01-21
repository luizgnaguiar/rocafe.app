import XCTest
import GRDB
@testable import rocafe

final class BackupServiceTests: XCTestCase {
    
    var testDir: URL!
    var dbPool: DatabasePool!
    var backupService: BackupService!
    var dbPath: URL!
    var backupsDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // 1. Create a unique temporary directory for this test run
        testDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true, attributes: nil)
        
        dbPath = testDir.appendingPathComponent("rocafe.sqlite")
        backupsDir = testDir.appendingPathComponent("Backups")
        
        // 2. Setup the database pool at the temporary path
        dbPool = try DatabasePool(path: dbPath.path)
        
        // Run migrations
        var migrator = DatabaseMigrator()
        AppMigrations.register(migrator: &migrator)
        try migrator.migrate(dbPool)
        
        // 3. Initialize BackupService with the temporary paths
        backupService = try BackupService(dbPath: dbPath, backupsDirectory: backupsDir)
    }

    override func tearDownWithError() throws {
        dbPool = nil
        backupService = nil
        try? FileManager.default.removeItem(at: testDir)
        testDir = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Block 2.2: Backup Tests

    func test_ManualBackup_CreatesValidAndCorrectFile() async throws {
        // MARK: Arrange
        // 1. Add some data to the database
        let customerName = "Test Customer"
        var customer = Customer(name: customerName, isActive: true)
        try await dbPool.write { db in
            try customer.save(db)
        }
        
        // 2. Define a destination for the backup
        let backupURL = backupsDir.appendingPathComponent("test-backup.sqlite")
        
        // MARK: Act
        // 3. Perform the backup
        try backupService.performManualBackup(to: backupURL)
        
        // MARK: Assert
        // 4. Check that the backup file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path), "Backup file should exist.")
        
        // 5. Verify the integrity and content of the backup file
        let backupDbPool = try DatabasePool(path: backupURL.path)
        let backedUpCustomer = try await backupDbPool.read { db in
            try Customer.fetchOne(db)
        }
        
        XCTAssertNotNil(backedUpCustomer, "Backup database should contain the customer.")
        XCTAssertEqual(backedUpCustomer?.name, customerName, "Customer name in backup should match the original.")
    }
    
    /// This test covers both `verifyBackupIntegrity` and the pre-restore safety backup
    func test_Restore_ReplacesDataCorrectly() async throws {
        // MARK: Arrange
        // 1. Setup DB v1 with "Data A" and create a backup of it
        var customerA = Customer(name: "Data A", isActive: true)
        try await dbPool.write { db in try customerA.save(db) }
        
        let backupURL = backupsDir.appendingPathComponent("backup-v1.sqlite")
        try backupService.performManualBackup(to: backupURL)
        
        // 2. "Corrupt" the main DB by replacing it with "Data B"
        // First, clear the existing DB
        _ = try await dbPool.write { db in try Customer.deleteAll(db) }
        var customerB = Customer(name: "Data B", isActive: true)
        try await dbPool.write { db in try customerB.save(db) }

        // Verify that the DB now contains Data B
        let customerInDbBeforeRestore = try await dbPool.read { db in try Customer.fetchOne(db) }
        XCTAssertEqual(customerInDbBeforeRestore?.name, "Data B")
        
        // MARK: Act
        // 3. Restore from the backup of "Data A"
        try backupService.restore(from: backupURL)
        
        // The service replaces the file, so we need to reconnect to it
        let restoredDbPool = try DatabasePool(path: dbPath.path)
        
        // MARK: Assert
        // 4. The database should now contain "Data A"
        let customerInDbAfterRestore = try await restoredDbPool.read { db in try Customer.fetchOne(db) }
        XCTAssertEqual(customerInDbAfterRestore?.name, "Data A", "Database should be restored to Data A.")
        
        // 5. The pre-restore backup should exist and contain "Data B"
        let preRestoreFiles = try FileManager.default.contentsOfDirectory(at: backupsDir, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.contains("rocafe-pre-restore-") }
        
        XCTAssertEqual(preRestoreFiles.count, 1, "There should be one pre-restore backup file.")
        
        let preRestoreBackupURL = preRestoreFiles[0]
        let preRestoreDbPool = try DatabasePool(path: preRestoreBackupURL.path)
        let customerInPreRestoreBackup = try await preRestoreDbPool.read { db in try Customer.fetchOne(db) }
        
        XCTAssertEqual(customerInPreRestoreBackup?.name, "Data B", "Pre-restore backup should contain Data B.")
    }
}
