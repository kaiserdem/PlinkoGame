import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PlinkoTheme {
    struct Palette {
        static let primaryRed = Color(hex: "#FF1744")
        static let darkRed = Color(hex: "#B71C1C")
        static let deepRed = Color(hex: "#8D0000")
        static let black = Color(hex: "#000000")
        static let darkGray = Color(hex: "#212121")
        
        static let deepPurple = Color(hex: "4A148C")
        static let purple = Color(hex: "7B1FA2")
        static let lightPurple = Color(hex: "E1BEE7")
        static let pinkPurple = Color(hex: "C2185B")
        
        static let gold = Color(hex: "FFD700")
        static let green = Color(hex: "4CAF50")
        static let blue = Color(hex: "2196F3")
        
        static let background = Color(hex: "#1A1A1A")
        static let surface = Color(hex: "#2A2A2A")
        static let cardBackground = Color(hex: "#1E1E1E")
        
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "#CCCCCC")
        static let textTertiary = Color(hex: "#999999")
        
        static let accent = Color(hex: "#FF6B6B")
        static let success = Color(hex: "#4CAF50")
        static let warning = Color(hex: "#FF9800")
        
        static let backgroundDark = Color(hex: "#0A001A")
        static let backgroundAccentPurple = Color(hex: "#300040")
        static let backgroundAccentBlue = Color(hex: "#002050")
        
        static let spherePrimary = Color(hex: "#E020F0")
        static let sphereSecondary = Color(hex: "#700070")
        static let sphereHighlight = Color(hex: "#FFFFFF")
        static let sphereGlow = Color(hex: "#FF40FF")
        
        static let electricBlue = Color(hex: "#0080FF")
        static let glowingPurple = Color(hex: "#A020F0")
        static let neonPink = Color(hex: "#FF20A0")
        static let neonCyan = Color(hex: "#00FFFF")
        
        static let pinColor = Color(hex: "#FFEEEE")
        static let pinGlow = Color(hex: "#FFFFFF")
        
        static let slotRed = Color(hex: "#FF4081")
        static let slotOrange = Color(hex: "#FF9800")
        static let slotYellow = Color(hex: "#FFEB3B")
        static let slotGreen = Color(hex: "#8BC34A")
        static let slotBlue = Color(hex: "#2196F3")
        static let slotPurple = Color(hex: "#9C27B0")
        static let slotPink = Color(hex: "#E91E63")
    }
    
    struct Gradient {
        static let background = LinearGradient(
            colors: [
                Palette.primaryRed,
                Palette.deepRed,
                Palette.darkRed,
                Palette.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundPurple = LinearGradient(
            colors: [Palette.deepPurple, Palette.black],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        
        static let backgroundPink = LinearGradient(
            colors: [Palette.deepPurple, Palette.pinkPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let navigationBar = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed, Palette.darkRed, Palette.primaryRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let tabBar = LinearGradient(
            colors: [
                Palette.black,
                Palette.deepRed,
                Palette.deepRed,
                Palette.primaryRed
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let button = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let surface = LinearGradient(
            colors: [Palette.surface, Palette.deepRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let gold = LinearGradient(
            colors: [Palette.gold, Color(hex: "FFA000")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let purple = LinearGradient(
            colors: [Palette.purple, Palette.lightPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let gameFieldBackground = LinearGradient(
            colors: [
                Palette.backgroundDark,
                Palette.backgroundAccentPurple,
                Palette.backgroundAccentBlue,
                Palette.backgroundDark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let sphere = LinearGradient(
            colors: [
                Palette.sphereHighlight.opacity(0.9),
                Palette.spherePrimary,
                Palette.sphereSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let sphereRadialGlow = RadialGradient(
            colors: [
                Palette.sphereHighlight.opacity(0.8),
                Palette.spherePrimary.opacity(0.7),
                Palette.sphereSecondary.opacity(0.5),
                Palette.sphereGlow.opacity(0.3)
            ],
            center: .topLeading,
            startRadius: 0,
            endRadius: 50
        )
        
        static let electricGlow = LinearGradient(
            colors: [
                Palette.electricBlue.opacity(0.8),
                Palette.glowingPurple.opacity(0.6),
                Palette.neonPink.opacity(0.4),
                Palette.backgroundDark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let buttonPrimary = LinearGradient(
            colors: [
                Palette.spherePrimary,
                Palette.sphereSecondary,
                Palette.purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let pinGlow = RadialGradient(
            colors: [
                Palette.pinGlow.opacity(0.8),
                Palette.pinColor.opacity(0.6),
                Palette.pinColor.opacity(0.3)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 10
        )
        
        static let slotGradient = LinearGradient(
            colors: [
                Palette.slotPurple,
                Palette.slotPink,
                Palette.slotRed
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Shadow {
        static let red = Color(hex: "FF2D55").opacity(0.3)
        static let purple = Color(hex: "7B1FA2").opacity(0.3)
        static let gold = Color(hex: "FFD700").opacity(0.3)
        
        static let sphereShadow = Palette.sphereSecondary.opacity(0.6)
        static let sphereGlow = Palette.sphereGlow.opacity(0.8)
        static let blueGlow = Palette.electricBlue.opacity(0.5)
        static let purpleGlow = Palette.glowingPurple.opacity(0.5)
        static let pinGlow = Palette.pinGlow.opacity(0.7)
        static let neonGlow = Palette.neonCyan.opacity(0.4)
    }
    
    struct Animation {
        static let glowPulse = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let fastGlow = SwiftUI.Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        static let slowRotation = SwiftUI.Animation.linear(duration: 10.0).repeatForever(autoreverses: false)
        static let bounce = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
    }
}
