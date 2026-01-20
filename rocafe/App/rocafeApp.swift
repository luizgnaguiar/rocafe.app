import SwiftUI

@main
struct rocafeApp: App {
    
    // Initialize the database manager as soon as the app starts.
    let _ = DatabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(DefaultWindowStyle())
        .commands {
            // You can add custom menu commands here if needed
        }
    }
}
