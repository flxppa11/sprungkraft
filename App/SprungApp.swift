import SwiftUI

@main
struct SprungApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(Theme.accent)
        }
    }
}
