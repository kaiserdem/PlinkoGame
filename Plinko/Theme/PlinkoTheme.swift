//
//  PlinkoTheme.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import SwiftUI

extension Color {
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
        // Основні кольори з більшим контрастом (як у Aviator_v2)
        static let primaryRed = Color(hex: "#FF1744")       // Яскраво-червоний акцент
        static let darkRed = Color(hex: "#B71C1C")          // Темно-червоний
        static let deepRed = Color(hex: "#8D0000")           // Глибокий червоний
        static let black = Color(hex: "#000000")             // Чорний
        static let darkGray = Color(hex: "#212121")          // Темно-сірий
        
        // Пурпурові градієнти
        static let deepPurple = Color(hex: "4A148C")       // Темно-пурпуровий
        static let purple = Color(hex: "7B1FA2")          // Пурпуровий
        static let lightPurple = Color(hex: "E1BEE7")     // Світло-пурпуровий
        static let pinkPurple = Color(hex: "C2185B")      // Пурпурово-рожевий
        
        // Акцентні кольори
        static let gold = Color(hex: "FFD700")            // Золотий/жовтий
        static let green = Color(hex: "4CAF50")          // Зелений
        static let blue = Color(hex: "2196F3")           // Синій
        
        // Фонові кольори
        static let background = Color(hex: "#1A1A1A")        // Темний фон
        static let surface = Color(hex: "#2A2A2A")           // Темна поверхня
        static let cardBackground = Color(hex: "#1E1E1E")    // Фон карток
        
        // Текстові кольори
        static let textPrimary = Color.white                 // Білий текст
        static let textSecondary = Color(hex: "#CCCCCC")    // Світло-сірий текст
        static let textTertiary = Color(hex: "#999999")     // Сірий текст
        
        // Акцентні кольори
        static let accent = Color(hex: "#FF6B6B")           // Світло-червоний акцент
        static let success = Color(hex: "#4CAF50")           // Зелений для успіху
        static let warning = Color(hex: "#FF9800")           // Помаранчевий для попереджень
        
        // MARK: - Plinko Specific Palette (на основі футуристичного дизайну)
        // Фонові кольори
        static let backgroundDark = Color(hex: "#0A001A")       // Дуже темний, майже чорний з фіолетовим відтінком
        static let backgroundAccentPurple = Color(hex: "#300040") // Глибокий фіолетовий для фонових елементів
        static let backgroundAccentBlue = Color(hex: "#002050") // Темно-синій для фонових елементів
        
        // Кольори кульки (футуристична магента)
        static let spherePrimary = Color(hex: "#E020F0")        // Яскрава магента для кульки
        static let sphereSecondary = Color(hex: "#700070")      // Темніша магента/пурпур для країв кульки
        static let sphereHighlight = Color(hex: "#FFFFFF")      // Білий відблиск на кульці
        static let sphereGlow = Color(hex: "#FF40FF")           // Світіння кульки
        
        // Акцентні кольори (неонові свічення)
        static let electricBlue = Color(hex: "#0080FF")         // Яскравий електричний синій акцент
        static let glowingPurple = Color(hex: "#A020F0")        // Світліший фіолетовий для свічення
        static let neonPink = Color(hex: "#FF20A0")             // Неоновий рожевий
        static let neonCyan = Color(hex: "#00FFFF")             // Неоновий блакитний
        
        // Кольори пінів та інших дрібних елементів
        static let pinColor = Color(hex: "#FFEEEE")             // Майже білий/світло-рожевий для пінів
        static let pinGlow = Color(hex: "#FFFFFF")              // Біле світіння пінів
        
        // Кольори слотів (футуристичні варіанти)
        static let slotRed = Color(hex: "#FF4081")              // Рожево-червоний
        static let slotOrange = Color(hex: "#FF9800")           // Помаранчевий
        static let slotYellow = Color(hex: "#FFEB3B")           // Жовтий
        static let slotGreen = Color(hex: "#8BC34A")            // Зелений
        static let slotBlue = Color(hex: "#2196F3")             // Синій
        static let slotPurple = Color(hex: "#9C27B0")          // Пурпуровий
        static let slotPink = Color(hex: "#E91E63")            // Рожевий
    }
    
    struct Gradient {
        // Основний градієнт фону з більшим контрастом (як у Aviator_v2)
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
        
        // Навігаційні градієнти
        static let navigationBar = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed, Palette.darkRed, Palette.primaryRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для таббару (як у Aviator_v2)
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
        
        // Кнопки та елементи
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
        
        // Акцентні градієнти
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
        
        // MARK: - Plinko Specific Gradients (футуристичний стиль)
        // Градієнт для фону ігрового поля
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
        
        // Градієнт для кульки (основний)
        static let sphere = LinearGradient(
            colors: [
                Palette.sphereHighlight.opacity(0.9),
                Palette.spherePrimary,
                Palette.sphereSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Радіальний градієнт для кульки (для ефекту глянцю/свічення)
        static let sphereRadialGlow = RadialGradient(
            colors: [
                Palette.sphereHighlight.opacity(0.8), // Яскравий центр
                Palette.spherePrimary.opacity(0.7),
                Palette.sphereSecondary.opacity(0.5),
                Palette.sphereGlow.opacity(0.3)
            ],
            center: .topLeading, // Відблиск зверху зліва
            startRadius: 0,
            endRadius: 50
        )
        
        // Градієнт для неонових свічень на фоні
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
        
        // Градієнт для кнопок або інтерактивних елементів
        static let buttonPrimary = LinearGradient(
            colors: [
                Palette.spherePrimary,
                Palette.sphereSecondary,
                Palette.purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для пінів
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
        
        // Градієнт для слотів
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
        
        // MARK: - Plinko Specific Shadows
        static let sphereShadow = Palette.sphereSecondary.opacity(0.6) // Тінь для кульки
        static let sphereGlow = Palette.sphereGlow.opacity(0.8) // Світіння кульки
        static let blueGlow = Palette.electricBlue.opacity(0.5) // Світіння для синіх акцентів
        static let purpleGlow = Palette.glowingPurple.opacity(0.5) // Світіння для фіолетових акцентів
        static let pinGlow = Palette.pinGlow.opacity(0.7) // Світіння пінів
        static let neonGlow = Palette.neonCyan.opacity(0.4) // Неонове світіння
    }
    
    struct Animation {
        // Анімації для футуристичного ефекту
        static let glowPulse = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let fastGlow = SwiftUI.Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        static let slowRotation = SwiftUI.Animation.linear(duration: 10.0).repeatForever(autoreverses: false)
        static let bounce = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
    }
}
