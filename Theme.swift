import SwiftUI

// Modern spy-themed design system
struct Theme {

    // MARK: - Colors

    struct Colors {
        // Primary palette - dark, sophisticated spy theme
        static let background = Color(red: 0.08, green: 0.09, blue: 0.12) // Almost black
        static let surface = Color(red: 0.12, green: 0.14, blue: 0.18) // Dark card background
        static let surfaceElevated = Color(red: 0.16, green: 0.18, blue: 0.22)

        // Accent - stealth green with mystery
        static let primary = Color(red: 0.2, green: 0.95, blue: 0.6) // Bright matrix green
        static let primaryDim = Color(red: 0.15, green: 0.7, blue: 0.45)

        // Secondary - subtle blue for contrast
        static let secondary = Color(red: 0.3, green: 0.7, blue: 0.95)
        static let secondaryDim = Color(red: 0.2, green: 0.5, blue: 0.7)

        // Status colors
        static let success = Color(red: 0.2, green: 0.95, blue: 0.6)
        static let warning = Color(red: 0.95, green: 0.7, blue: 0.2)
        static let danger = Color(red: 0.95, green: 0.3, blue: 0.3)

        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(white: 0.7)
        static let textTertiary = Color(white: 0.5)

        // Message bubbles
        static let messageSent = LinearGradient(
            colors: [Color(red: 0.2, green: 0.95, blue: 0.6), Color(red: 0.15, green: 0.75, blue: 0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let messageReceived = Color(red: 0.16, green: 0.18, blue: 0.22)
    }

    // MARK: - Typography

    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

        // Monospace for codes
        static let mono = Font.system(size: 17, weight: .medium, design: .monospaced)
        static let monoLarge = Font.system(size: 24, weight: .bold, design: .monospaced)
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
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: - Shadows

    struct Shadows {
        static let small = Shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)
        static let medium = Shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
        static let large = Shadow(color: Color.black.opacity(0.5), radius: 16, y: 8)

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
            .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius * 2)
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func glow(color: Color = Theme.Colors.primary, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }

    func pulse() -> some View {
        modifier(PulseEffect())
    }
}
