import SwiftUI

// Ultra-minimal, sleek design - modern iOS style
struct Theme {

    // MARK: - Colors

    struct Colors {
        static let background = Color(red: 0.99, green: 0.99, blue: 1.0)
        static let surface = Color.white
        static let surfaceSecondary = Color(red: 0.97, green: 0.97, blue: 0.98)

        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0)
        static let primaryLight = Color(red: 0.4, green: 0.7, blue: 1.0)

        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let danger = Color(red: 1.0, green: 0.23, blue: 0.19)

        static let textPrimary = Color(red: 0.09, green: 0.09, blue: 0.09)
        static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)
        static let textTertiary = Color(red: 0.78, green: 0.78, blue: 0.8)

        static let messageSent = LinearGradient(
            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.3, green: 0.6, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let messageReceived = Color(red: 0.95, green: 0.95, blue: 0.96)

        static let border = Color(red: 0.9, green: 0.9, blue: 0.92)
        static let divider = Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    // MARK: - Typography - Smaller, tighter

    struct Typography {
        static let largeTitle = Font.system(size: 26, weight: .bold)
        static let title = Font.system(size: 20, weight: .bold)
        static let title2 = Font.system(size: 17, weight: .semibold)
        static let headline = Font.system(size: 15, weight: .semibold)
        static let body = Font.system(size: 15, weight: .regular)
        static let callout = Font.system(size: 14, weight: .regular)
        static let subheadline = Font.system(size: 13, weight: .regular)
        static let footnote = Font.system(size: 12, weight: .regular)
        static let caption = Font.system(size: 11, weight: .regular)
        static let caption2 = Font.system(size: 10, weight: .regular)
    }

    // MARK: - Spacing - Tighter, minimal

    struct Spacing {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
        static let xl: CGFloat = 18
        static let xxl: CGFloat = 24
    }

    // MARK: - Corner Radius - Subtle

    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
        static let xl: CGFloat = 18
        static let full: CGFloat = 999
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(isEnabled ? Theme.Colors.primary : Theme.Colors.textTertiary)
            .cornerRadius(Theme.CornerRadius.md)
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
