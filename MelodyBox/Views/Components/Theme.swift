import SwiftUI

// MARK: - MelodyBox Design System & Theme
public enum Theme {
    // Primary Color Palette
    public static let background = Color(hex: "08070D") // Deepest obsidian black
    public static let surface = Color(hex: "13101E")    // Dark violet card surface
    public static let surfaceElevated = Color(hex: "1B162C") // Elevated element
    public static let surfaceBorder = Color(hex: "2D2447")   // Subtle purple border
    
    // Neon Accents
    public static let purple = Color(hex: "A855F7")       // Vibrant electric purple
    public static let darkPurple = Color(hex: "6D28D9")   // Deep violet
    public static let glow = Color(hex: "C084FC")         // Bright neon lilac glow
    public static let accent = Color(hex: "EC4899")       // Neon magenta highlight
    public static let cyan = Color(hex: "06B6D4")         // Cyan accent
    
    // Status & License Colors
    public static let success = Color(hex: "10B981")      // Emerald (Lawful / Authorized)
    public static let warning = Color(hex: "F59E0B")      // Amber (Stream-only / Attribution)
    public static let error = Color(hex: "EF4444")        // Coral red
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: "9CA3AF")
    public static let textTertiary = Color(hex: "6B7280")

    // Gradients
    public static let purpleGradient = LinearGradient(
        colors: [purple, darkPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let heroGradient = LinearGradient(
        colors: [purple, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardGradient = LinearGradient(
        colors: [surfaceElevated.opacity(0.85), surface.opacity(0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let backgroundGradient = RadialGradient(
        gradient: Gradient(colors: [Color(hex: "24123E").opacity(0.4), background]),
        center: .top,
        startRadius: 40,
        endRadius: 550
    )
    
    public static let waveformGradient = LinearGradient(
        colors: [cyan, purple, accent],
        startPoint: .bottom,
        endPoint: .top
    )
}

// MARK: - Color Hex Initializer
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Glassmorphism View Modifier
public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var strokeColor: Color = Theme.surfaceBorder
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.surface.opacity(0.85))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.25))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [strokeColor.opacity(0.8), strokeColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 16, strokeColor: Color = Theme.surfaceBorder) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, strokeColor: strokeColor))
    }
    
    func purpleGlow(radius: CGFloat = 12, opacity: Double = 0.4) -> some View {
        self.shadow(color: Theme.purple.opacity(opacity), radius: radius, x: 0, y: 4)
    }
}

// MARK: - Time Formatting Helpers
public extension TimeInterval {
    var formattedDuration: String {
        guard !self.isNaN && !self.isInfinite && self > 0 else { return "0:00" }
        let totalSeconds = Int(self.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remMinutes = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remMinutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
