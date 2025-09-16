//
//  ContentView.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var game = PlinkoGameViewModel()
    
    var body: some View {
        ZStack {
            // Футуристичний фон на весь екран
            PlinkoTheme.Gradient.gameFieldBackground
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                gameTitleView
                
                Spacer()
                
                gameStatsView
                
                Spacer()
                
                gameFieldView
                
                Spacer()
                
                controlButtonsView
            }
        }
        .onAppear {
            // Отримуємо розміри екрану
            let screenBounds = UIScreen.main.bounds
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            
            print("📱 Screen bounds: \(screenBounds)")
            print("📱 Screen width: \(screenWidth)")
            print("📱 Screen height: \(screenHeight)")
            print("📱 Screen scale: \(UIScreen.main.scale)")
            
            // Також спробуємо через window
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                print("📱 Window size: \(windowScene.screen.bounds)")
            }
        }
    }
    
    // MARK: - Game Title View
    private var gameTitleView: some View {
        Text("Plinko Game")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(PlinkoTheme.Palette.spherePrimary)
            .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 10)
            .padding(.top, 10)
    }
    
    // MARK: - Game Stats View
    private var gameStatsView: some View {
        HStack(spacing: 20) {
            StatView(title: "Score", value: game.score, color: PlinkoTheme.Palette.electricBlue, shadow: PlinkoTheme.Shadow.blueGlow)
            StatView(title: "Best", value: game.bestScore, color: PlinkoTheme.Palette.gold, shadow: PlinkoTheme.Shadow.gold)
            StatView(title: "Games", value: game.totalGames, color: PlinkoTheme.Palette.neonPink, shadow: PlinkoTheme.Shadow.neonGlow)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Game Field View
    private var gameFieldView: some View {
        ZStack {
            // Ігрове поле з футуристичним фоном
            RoundedRectangle(cornerRadius: 15)
                .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(PlinkoTheme.Gradient.electricGlow, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.purpleGlow, radius: 20)
                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 300) // Динамічні розміри з відступами
            
            pinsView  // точки
            slotsView // кольора
            ballView
            celebrationView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Pins View
    private var pinsView: some View {
        ForEach(Array(game.getPins().enumerated()), id: \.offset) { _, pin in
            ZStack {
                // Світіння піна
                Circle()
                    .fill(PlinkoTheme.Palette.pinGlow)
                    .frame(width: pin.radius * 3, height: pin.radius * 3)
                    .blur(radius: 3)
                    .opacity(0.6)
                
                // Основний пін
                Circle()
                    .fill(PlinkoTheme.Gradient.pinGlow)
                    .frame(width: pin.radius * 2, height: pin.radius * 2)
            }
            .position(pin.position)
            .shadow(color: PlinkoTheme.Shadow.pinGlow, radius: 5)
        }
    }
    
    // MARK: - Slots View
    private var slotsView: some View {
        ForEach(Array(game.getSlots().enumerated()), id: \.offset) { _, slot in
            VStack(spacing: 2) {
                ZStack {
                    // Світіння слота
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PlinkoTheme.Palette.neonPink.opacity(0.7))
                        .frame(width: slot.rect.width + 4, height: slot.rect.height + 4)
                        .blur(radius: 2)
                        .opacity(0.7)
                    
                    // Основний слот
                    RoundedRectangle(cornerRadius: 6)
                        .fill(slot.color)
                        .frame(width: slot.rect.width, height: slot.rect.height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 1)
                        )
                }
                
                Text("\(slot.points)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    .shadow(color: PlinkoTheme.Palette.neonPink, radius: 3)
            }
            .position(x: slot.rect.midX, y: slot.rect.midY + 25)
        }
    }
    
    // MARK: - Ball View
    private var ballView: some View {
        Group {
            if let ball = game.ball {
                ZStack {
                    // Зовнішнє світіння кульки
                    Circle()
                        .fill(PlinkoTheme.Palette.sphereGlow)
                        .frame(width: ball.radius * 4, height: ball.radius * 4)
                        .blur(radius: 8)
                        .opacity(0.8)
                    
                    // Радіальний градієнт кульки
                    Circle()
                        .fill(PlinkoTheme.Gradient.sphereRadialGlow)
                        .frame(width: ball.radius * 2, height: ball.radius * 2)
                    
                    // Внутрішнє світіння
                    Circle()
                        .fill(PlinkoTheme.Palette.sphereHighlight.opacity(0.3))
                        .frame(width: ball.radius, height: ball.radius)
                        .blur(radius: 2)
                }
                .position(ball.position)
                .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 15)
            }
        }
    }
    
    // MARK: - Celebration View
    private var celebrationView: some View {
        Group {
            if game.showCelebration {
                VStack {
                    Text("🎉 NEW RECORD! 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(PlinkoTheme.Palette.gold)
                        .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
                    
                    Text("\(game.score) points!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                        .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 8)
                }
                .scaleEffect(game.showCelebration ? 1.2 : 1.0)
                .animation(PlinkoTheme.Animation.glowPulse, value: game.showCelebration)
            }
        }
    }
    
    // MARK: - Control Buttons View
    private var controlButtonsView: some View {
        HStack(spacing: 15) {
            Button(action: {
                game.startGame()
            }) {
                HStack {
                    Image(systemName: game.isPlaying ? "play.circle.fill" : "play.circle")
                    Text(game.isPlaying ? "Playing..." : "Start Game")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if game.isPlaying {
                            PlinkoTheme.Palette.darkGray
                        } else {
                            PlinkoTheme.Gradient.buttonPrimary
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            game.isPlaying ? 
                            PlinkoTheme.Palette.textTertiary : 
                            PlinkoTheme.Palette.spherePrimary, 
                            lineWidth: 2
                        )
                )
                .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 8)
            }
            .disabled(game.isPlaying)
            
            Button(action: {
                game.resetStats()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                    Text("Reset")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(PlinkoTheme.Palette.primaryRed)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.red, radius: 8)
            }
            .disabled(game.isPlaying)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat View Component
struct StatView: View {
    let title: String
    let value: Int
    let color: Color
    let shadow: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption2)
                .foregroundColor(PlinkoTheme.Palette.textSecondary)
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
                .shadow(color: shadow, radius: 5)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
