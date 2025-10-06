import SwiftUI

struct ContentView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                DiscoveryView()
                    .tag(0)

                NavigationView {
                    ChatsListView()
                }
                .tag(1)

                SettingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar
            ModernTabBar(selectedTab: $selectedTab, peerService: peerService)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var peerService: PeerService

    var body: some View {
        HStack(spacing: 0) {
            // Discovery Tab
            TabBarButton(
                icon: "antenna.radiowaves.left.and.right",
                title: "SCAN",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )

            // Messages Tab
            ZStack(alignment: .topTrailing) {
                TabBarButton(
                    icon: "message.fill",
                    title: "MSGS",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )

                // Badge for connected peers
                if !peerService.connectedPeers.isEmpty {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 8, height: 8)
                        .offset(x: 8, y: 12)
                        .glow(color: Theme.Colors.primary, radius: 4)
                }
            }

            // Settings Tab
            TabBarButton(
                icon: "gearshape.fill",
                title: "SYS",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            Theme.Colors.surface
                .overlay(
                    Theme.Colors.primary.opacity(0.05)
                )
        )
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.5), radius: 20, y: -5)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)
                    .glow(color: isSelected ? Theme.Colors.primary : .clear, radius: 6)

                Text(title)
                    .font(Theme.Typography.caption2)
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                isSelected ?
                Theme.Colors.primary.opacity(0.15) :
                Color.clear
            )
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PeerService())
}
