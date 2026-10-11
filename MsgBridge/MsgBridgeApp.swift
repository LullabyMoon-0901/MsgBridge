import SwiftUI

@main
struct MsgBridgeApp: App {
    @StateObject private var store = MessageStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
