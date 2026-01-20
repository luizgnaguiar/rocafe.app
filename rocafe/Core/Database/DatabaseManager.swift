import Foundation
import GRDB

// Presumes that GRDB.swift is added as a package dependency to the project.
// For more info, see: https://github.com/groue/GRDB.swift

final class DatabaseManager {
    
    /// A shared instance of the DatabaseManager.
    static let shared = DatabaseManager()
    
    /// The database queue for writing and reading.
    let dbQueue: DatabaseQueue
    
    private init() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("rocafe")
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            
            let databaseURL = directoryURL.appendingPathComponent("rocafe.sqlite")
            
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            
            // Run migrations
            try migrator.migrate(dbQueue)
            
        } catch {
            // This is a critical error. In a real app, you might want to show an
            // alert to the user and then terminate the app.
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    /// The database migrator.
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Erase and re-create the database for development and testing
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        // Register migrations
        AppMigrations.register(migrator: &migrator)
        
        return migrator
    }
}
