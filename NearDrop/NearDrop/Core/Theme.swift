import SwiftUI

// Modern social media-inspired design system (Twitter/Instagram/Threads aesthetic)
struct Theme {

    // MARK: - Colors

    struct Colors {
        // Light, clean backgrounds
        static let background = Color(red: 0.98, green: 0.98, blue: 1.0) // Almost white with slight blue tint
        static let surface = Color.white
        static let surfaceSecondary = Color(red: 0.96, green: 0.96, blue: 0.98)

        // Modern vibrant accent - Instagram gradient inspired
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Bright iOS blue
        static let primaryLight = Color(red: 0.4, green: 0.7, blue: 1.0)

        // Secondary accent - purple for variety
        static let secondary = Color(red: 0.58, green: 0.4, blue: 0.95) // Vibrant purple
        static let secondaryLight = Color(red: 0.7, green: 0.6, blue: 1.0)

        // Status colors - modern and friendly
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // Fresh green
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // Warm orange
        static let danger = Color(red: 1.0, green: 0.23, blue: 0.19) // Bright red

        // Text - high contrast for readability
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Near black
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.47) // Gray
        static let textTertiary = Color(red: 0.7, green: 0.7, blue: 0.72) // Light gray

        // Message bubbles - like iMessage
        static let messageSent = LinearGradient(
            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.3, green: 0.6, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let messageReceived = Color(red: 0.92, green: 0.92, blue: 0.94)

        // Borders and dividers
        static let border = Color(red: 0.88, green: 0.88, blue: 0.9)
        static let divider = Color(red: 0.92, green: 0.92, blue: 0.94)
    }

    // MARK: - Typography

    struct Typography {
        // San Francisco font (iOS default) - clean and modern
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 999
    }

    // MARK: - Shadows

    struct Shadows {
        static let light = Shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        static let medium = Shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        static let large = Shadow(color: Color.black.opacity(0.1), radius: 16, y: 8)

        struct Shadow {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat

            init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
                self.color = color
                self.radius = radius
                self.x = x
                self.y = y
            }
        }
    }
}

// MARK: - Custom View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isEnabled ? Theme.Colors.primary : Theme.Colors.textTertiary
            )
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(color: Theme.Colors.primary.opacity(isEnabled ? 0.3 : 0), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func primaryButton(enabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: enabled))
    }
}
