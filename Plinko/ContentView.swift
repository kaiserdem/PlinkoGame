//
//  ContentView.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//
//874

import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var game = PlinkoGameViewModel()
    
    var body: some View {
        ZStack {
            // Футуристичний фон на весь екран
            PlinkoTheme.Gradient.gameFieldBackground
                .ignoresSafeArea()
            
            // Відображаємо різні екрани залежно від поточного стану
            switch game.currentScreen {
            case .game:
                VStack(spacing: 10) {
                    gameTitleView
                    
                    Spacer()
                    
                    gameStatsWithNavigationView
                    
                    Spacer()
                    
                    gameFieldView
                    
                    Spacer()
                    
                    controlButtonsView
                }
            case .settings:
                settingsScreen
            case .rating:
                ratingScreen
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
    // MARK: - Game Stats with Navigation View
    private var gameStatsWithNavigationView: some View {
        HStack(spacing: 15) {
            // Кругла кнопка рейтингу (зліва)
            Button(action: {
                game.showRating()
            }) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(PlinkoTheme.Palette.gold)
                            .overlay(
                                Circle()
                                    .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 2)
                            )
                    )
                    .shadow(color: PlinkoTheme.Shadow.gold, radius: 8)
            }
            
            // Статистика гри
            HStack(spacing: 15) {
                StatView(title: "Score", value: game.score, color: PlinkoTheme.Palette.electricBlue, shadow: PlinkoTheme.Shadow.blueGlow)
                StatView(title: "Total", value: game.totalScore, color: PlinkoTheme.Palette.spherePrimary, shadow: PlinkoTheme.Shadow.sphereGlow)
                StatView(title: "Best", value: game.bestScore, color: PlinkoTheme.Palette.gold, shadow: PlinkoTheme.Shadow.gold)
                StatView(title: "Games", value: game.totalGames, color: PlinkoTheme.Palette.neonPink, shadow: PlinkoTheme.Shadow.neonGlow)
            }
            .frame(maxWidth: .infinity)
            
            // Кругла кнопка налаштувань (справа)
            Button(action: {
                game.showSettings()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(PlinkoTheme.Palette.electricBlue)
                            .overlay(
                                Circle()
                                    .stroke(PlinkoTheme.Palette.spherePrimary, lineWidth: 2)
                            )
                    )
                    .shadow(color: PlinkoTheme.Shadow.blueGlow, radius: 8)
            }
        }
        .padding(.horizontal)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            
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
                // Світіння піна (без блюру)
                Circle()
                    .fill(PlinkoTheme.Palette.pinGlow)
                    .frame(width: pin.radius * 3, height: pin.radius * 3)
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
                    // Світіння слота (без блюру)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PlinkoTheme.Palette.neonPink.opacity(0.7))
                        .frame(width: slot.rect.width + 4, height: slot.rect.height + 4)
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
                    // Зовнішнє світіння кульки (рожево-магнетичне)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.pink.opacity(0.8),
                                    Color.purple.opacity(0.6),
                                    Color.purple.opacity(0.4)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: ball.radius * 2
                            )
                        )
                        .frame(width: ball.radius * 4, height: ball.radius * 4)
                        .blur(radius: 6)
                        .opacity(0.9)
                    
                    // Основний круг кульки з рожево-магнетичним градієнтом
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.9),
                                    Color.pink.opacity(0.8),
                                    Color.purple.opacity(0.7),
                                    Color.purple.opacity(0.9)
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: ball.radius
                            )
                        )
                        .frame(width: ball.radius * 2, height: ball.radius * 2)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.pink.opacity(0.8),
                                            Color.purple.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    // Внутрішній блик (білий центр)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.pink.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: ball.radius * 0.6
                            )
                        )
                        .frame(width: ball.radius * 1.2, height: ball.radius * 1.2)
                }
                .position(ball.position)
                .shadow(color: Color.pink.opacity(0.6), radius: 8)
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
    
    // MARK: - Settings Screen
    private var settingsScreen: some View {
        VStack(spacing: 20) {
            // Header
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 10)
            
            Spacer()
            
            // Physics settings
            VStack(spacing: 25) {
                // Bounce settings
                VStack(spacing: 12) {
                    Text("Bounce Strength")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 1.0))
                    
                    Picker("Bounce Strength", selection: $game.bounceStrength) {
                        ForEach(BounceStrength.allCases, id: \.self) { strength in
                            Text(strength.rawValue).tag(strength)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    )
                    .accentColor(Color(red: 0.0, green: 0.9, blue: 1.0))
                }
                
                // Gravity settings
                VStack(spacing: 12) {
                    Text("Gravity Strength")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 1.0))
                    
                    Picker("Gravity Strength", selection: $game.gravityStrength) {
                        ForEach(GravityStrength.allCases, id: \.self) { strength in
                            Text(strength.rawValue).tag(strength)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    )
                    .accentColor(Color(red: 0.0, green: 0.9, blue: 1.0))
                }
            }
            
            Spacer()
            
            // Кнопка повернення
            Button(action: {
                game.showGame()
            }) {
                HStack {
                    Image(systemName: "arrow.left.circle.fill")
                    Text("Back to Game")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(PlinkoTheme.Gradient.buttonPrimary)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(PlinkoTheme.Palette.spherePrimary, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 10)
            }
        }
        .padding()
    }
    
    // MARK: - Rating Screen
    private var ratingScreen: some View {
        VStack(spacing: 20) {
            // Header
            Text("Rating")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.gold)
                .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
            
            // Overall statistics for decision making
            if game.totalScore > 0 || game.totalGames > 0 {
                VStack(spacing: 15) {
                    Text("Player Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(PlinkoTheme.Palette.gold)
                
                HStack(spacing: 15) {
                    VStack {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        Text("\(game.totalScore)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.electricBlue)
                    }
                    
                    VStack {
                        Text("Best")
                            .font(.caption)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        Text("\(game.bestScore)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.gold)
                    }
                    
                    VStack {
                        Text("Games")
                            .font(.caption)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        Text("\(game.totalGames)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.neonPink)
                    }
                    
                    VStack {
                        Text("Efficiency")
                            .font(.caption)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        Text(String(format: "%.1f", game.efficiencyCoefficient))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PlinkoTheme.Palette.gold.opacity(0.5), lineWidth: 2)
                        )
                )
                }
            }
            
            // Save result form
            if game.score > 0 {
                VStack(spacing: 15) {
                    Text("Save Result: \(game.score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    
                    TextField("Enter your name", text: $game.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        game.saveScore()
                    }) {
                        Text("Save Score")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(PlinkoTheme.Palette.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(PlinkoTheme.Palette.gold)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 2)
                            )
                            .shadow(color: PlinkoTheme.Shadow.gold, radius: 8)
                    }
                    .disabled(game.playerName.isEmpty)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(PlinkoTheme.Palette.gold.opacity(0.5), lineWidth: 2)
                        )
                )
            }

            
            // Results list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(game.savedScores.enumerated()), id: \.element.id) { index, score in
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(index + 1).")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(PlinkoTheme.Palette.gold)
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(score.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                                
                                Spacer()
                                
                                Text("Efficiency: \(String(format: "%.1f", score.efficiencyCoefficient))")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                            }
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("Score")
                                        .font(.caption2)
                                        .foregroundColor(PlinkoTheme.Palette.textSecondary)
                                    Text("\(score.score)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(PlinkoTheme.Palette.electricBlue)
                                }
                                
                                VStack {
                                    Text("Total")
                                        .font(.caption2)
                                        .foregroundColor(PlinkoTheme.Palette.textSecondary)
                                    Text("\(score.totalScore)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                                }
                                
                                VStack {
                                    Text("Best")
                                        .font(.caption2)
                                        .foregroundColor(PlinkoTheme.Palette.textSecondary)
                                    Text("\(score.bestScore)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(PlinkoTheme.Palette.gold)
                                }
                                
                                VStack {
                                    Text("Games")
                                        .font(.caption2)
                                        .foregroundColor(PlinkoTheme.Palette.textSecondary)
                                    Text("\(score.totalGames)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(PlinkoTheme.Palette.neonPink)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(PlinkoTheme.Palette.neonPink.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            
            // Кнопка повернення
            Button(action: {
                game.showGame()
            }) {
                HStack {
                    Image(systemName: "arrow.left.circle.fill")
                    Text("Back to Game")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(PlinkoTheme.Gradient.buttonPrimary)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(PlinkoTheme.Palette.spherePrimary, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 10)
            }
        }
        .padding()
        .alert("Save Result", isPresented: $game.showSaveConfirmation) {
            Button("Cancel", role: .cancel) {
                game.cancelSaveScore()
            }
            Button("Save & Reset Game", role: .destructive) {
                game.confirmSaveScore()
            }
        } message: {
            Text("Do you agree to save the result and start a new session?")
        }
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
