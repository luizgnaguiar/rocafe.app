import Foundation
import GRDB
@testable import rocafe // Assuming the app module is named 'rocafe'

/// A helper struct to create and configure an in-memory database for testing purposes.
struct TestDatabase {
    
    /// Creates a new, migrated, in-memory database pool.
    /// - Returns: A fresh `DatabasePool` for a single test.
    static func newPool() throws -> DatabasePool {
        // Create an in-memory database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-pools
        let dbPool = try DatabasePool(configuration: Configuration(label: "rocafe-test"))
        
        // Get the app's migrator
        var migrator = DatabaseMigrator()
        AppMigrations.register(migrator: &migrator)
        
        // Run migrations
        try migrator.migrate(dbPool)
        
        return dbPool
    }
    
    /// Creates a new, migrated, in-memory database queue.
    /// - Returns: A fresh `DatabaseQueue` for a single test.
    static func newQueue() throws -> DatabaseQueue {
        // Create an in-memory database
        let dbQueue = try DatabaseQueue(configuration: Configuration(label: "rocafe-test"))
        
        // Get the app's migrator
        var migrator = DatabaseMigrator()
        AppMigrations.register(migrator: &migrator)
        
        // Run migrations
        try migrator.migrate(dbQueue)
        
        return dbQueue
    }
}
