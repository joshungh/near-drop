import SwiftUI

@main
struct NearDropApp: App {
    @StateObject private var peerService = PeerService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(peerService)
        }
    }
}
