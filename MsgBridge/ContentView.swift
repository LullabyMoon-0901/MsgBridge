import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: MessageStore

    var body: some View {
        TabView {
            MessageListView()
                .tabItem {
                    Label("消息", systemImage: "tray.full")
                }
                .badge(store.todoCount)

            SettingsView()
                .tabItem {
                    Label("同步", systemImage: "arrow.triangle.2.circlepath")
                }
        }
    }
}
