import SwiftUI

struct ContentView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "wave.3.right")
                }
                .tag(0)

            ChatsListView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PeerService())
}
