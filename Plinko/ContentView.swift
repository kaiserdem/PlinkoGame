
import SwiftUI

struct ContentView: View {
    @StateObject private var game = PlinkoGameViewModel()
    
    var body: some View {
        ZStack {
            PlinkoTheme.Gradient.gameFieldBackground
                .ignoresSafeArea()
            
            switch game.currentScreen {
            case .game:
                VStack(spacing: 10) {
                    gameTitleView
                    
                    
                gameStatsWithNavigationView
                    
                    shopAndBonusesButtonsView
                
                Spacer()
                
                gameFieldView
                
                Spacer()
                
                controlButtonsView
                }
            case .settings:
                settingsScreen
            case .rating:
                ratingScreen
            case .shop:
                shopScreen
            case .bonuses:
                bonusesScreen
            case .bonusDetail(let item):
                bonusDetailScreen(item: item)
            case .dailyBonus:
                dailyBonusScreen
            }
        }
        
    }
    
    // MARK: - Main Game Screen Components
    
    private var gameTitleView: some View {
        Text("Plinko Game")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(PlinkoTheme.Palette.spherePrimary)
            .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 10)
            .padding(.top, 10)
    }
    
    // MARK: - Statistics & Navigation
    
    private var gameStatsWithNavigationView: some View {
        HStack(spacing: 15) {
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
            
            HStack(spacing: 15) {
                StatView(title: "Score", value: game.score, color: PlinkoTheme.Palette.electricBlue, shadow: PlinkoTheme.Shadow.blueGlow)
                StatView(title: "Total", value: game.totalScore, color: PlinkoTheme.Palette.spherePrimary, shadow: PlinkoTheme.Shadow.sphereGlow)
                StatView(title: "Best", value: game.bestScore, color: PlinkoTheme.Palette.gold, shadow: PlinkoTheme.Shadow.gold)
                StatView(title: "Games", value: game.totalGames, color: PlinkoTheme.Palette.neonPink, shadow: PlinkoTheme.Shadow.neonGlow)
            }
            .frame(maxWidth: .infinity)
            
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
    
    // MARK: - Game Field Components
    
    private var gameFieldView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(PlinkoTheme.Gradient.electricGlow, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.purpleGlow, radius: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 0)
            
            pinsView
            slotsView
                .offset(y: game.se ? 10.0 : -10.0)
            ballView
            celebrationView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Pins View
    
    private var pinsView: some View {
        ForEach(Array(game.getPins().enumerated()), id: \.offset) { _, pin in
            ZStack {
                Circle()
                    .fill(PlinkoTheme.Palette.pinGlow)
                    .frame(width: pin.radius * 3, height: pin.radius * 3)
                    .opacity(0.6)
                
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
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PlinkoTheme.Palette.neonPink.opacity(0.7))
                        .frame(width: slot.rect.width + 4, height: slot.rect.height + 4)
                        .opacity(0.7)
                    
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
    
    // MARK: - Control Buttons
    
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
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 10)
            
            Spacer()
            
            VStack(spacing: 25) {
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
            
            Button(action: {
                game.showResetAllConfirmation()
            }) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                    Text("Reset All")
                }
                .font(.title3)
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(PlinkoTheme.Palette.primaryRed)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.red, radius: 10)
            }
            .padding(.top, 40)
            
            Spacer()
            
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
        .alert("Reset All Data", isPresented: $game.showResetConfirmation) {
            Button("Cancel", role: .cancel) {
                game.cancelResetAll()
            }
            Button("Reset All", role: .destructive) {
                game.confirmResetAll()
            }
        } message: {
            Text("This will permanently delete all your statistics and saved results. This action cannot be undone.\n\nDo you want to continue?")
        }
    }
    
    // MARK: - Rating Screen
    
    private var ratingScreen: some View {
        VStack(spacing: 20) {
            Text("Rating")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.gold)
                .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
            
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
    
    // MARK: - Shop & Bonuses Features
    
    private var shopAndBonusesButtonsView: some View {
        HStack(spacing: 20) {
            Button(action: {
                // Переходимо в магазин тільки якщо немає активного бонусу
                if game.currentActiveBonus == nil {
                    game.showShop()
                }
                // Якщо бонус активний - нічого не робимо
            }) {
                HStack {
                    Image(systemName: game.currentActiveBonus != nil ? getBonusIcon(for: game.currentActiveBonus!) : "cart.fill")
                    Text(getShopButtonText())
                }
                                .font(.title3)
                .fontWeight(.semibold)
                                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    game.currentActiveBonus != nil ? 
                    Color.orange.opacity(0.8) : 
                    PlinkoTheme.Palette.spherePrimary
                )
                .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            game.currentActiveBonus != nil ? 
                            Color.orange : 
                            PlinkoTheme.Palette.spherePrimary, 
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: game.currentActiveBonus != nil ? 
                    Color.orange.opacity(0.5) : 
                    PlinkoTheme.Shadow.sphereShadow, 
                    radius: 8
                )
            }
            
            Button(action: {
                game.showDailyBonus()
            }) {
                        HStack {
                    Image(systemName: "gift.fill")
                    Text("Bonuses")
                }
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
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    // MARK: - Shop Screen
    
    private var shopScreen: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Shop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                    .shadow(color: PlinkoTheme.Shadow.sphereGlow, radius: 10)
                            
                            Spacer()
                            
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(PlinkoTheme.Palette.gold)
                    Text("\(game.playerCoins)")
                        .font(.title2)
                                .fontWeight(.bold)
                        .foregroundColor(PlinkoTheme.Palette.gold)
                        }
                .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                                .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(PlinkoTheme.Palette.gold, lineWidth: 2)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            ScrollView {
                if game.shopItems.filter({ !$0.isPurchased }).isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(PlinkoTheme.Palette.gold)
                        
                        Text("All Items Purchased!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.gold)
                        
                        Text("You have purchased all available bonuses. Great job!")
                            .font(.body)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 60)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
                        ForEach(game.shopItems.filter { !$0.isPurchased }) { item in
                            ShopItemView(item: item, onPurchase: {
                                game.purchaseItem(item)
                            }, onTap: {
                                game.showBonusDetail(item)
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
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
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(PlinkoTheme.Gradient.buttonPrimary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PlinkoTheme.Palette.spherePrimary, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 8)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PlinkoTheme.Gradient.gameFieldBackground)
    }
    
    // MARK: - Bonuses Screen
    
    private var bonusesScreen: some View {
        VStack(spacing: 20) {
            Text("Bonuses")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.gold)
                .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
                .padding(.top, 40)
            
            Text("Coming Soon!")
                .font(.title2)
                .foregroundColor(PlinkoTheme.Palette.textSecondary)
                .padding(.vertical, 50)
            
            Spacer()
            
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
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PlinkoTheme.Gradient.gameFieldBackground)
    }
    
    
    // MARK: - Components
    
    
    
    // MARK: - Bonus Detail Screen
    
    private func bonusDetailScreen(item: ShopItem) -> some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: {
                    game.backToShop()
                }) {
                    HStack {
                        Image(systemName: "arrow.left.circle.fill")
                        Text("Back")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(item.color, lineWidth: 2)
                    )
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(PlinkoTheme.Palette.gold)
                    Text("\(game.playerCoins)")
                        .font(.title2)
                .fontWeight(.bold)
                        .foregroundColor(PlinkoTheme.Palette.gold)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(PlinkoTheme.Palette.gold, lineWidth: 2)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(item.color, lineWidth: 4)
                        )
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 50))
                        .foregroundColor(item.color)
                }
                .shadow(color: item.color.opacity(0.5), radius: 15)
                
                VStack(spacing: 15) {
                    Text(item.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(item.color)
                        .multilineTextAlignment(.center)
                    
                    Text(item.description)
                        .font(.title3)
                        .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(PlinkoTheme.Palette.gold)
                        Text("\(item.price) coins")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.gold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(PlinkoTheme.Palette.gold, lineWidth: 2)
                            )
                    )
                    
                    VStack(spacing: 8) {
                        Text("Effect Details:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(item.color)
                        
                        Text(getEffectDetails(for: item))
                            .font(.body)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(item.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            Button(action: {
                game.purchaseItem(item)
            }) {
                HStack {
                    Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "cart.fill")
                    Text(item.isPurchased ? "Owned" : "Purchase")
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.textPrimary)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(
                    item.isPurchased ?
                    PlinkoTheme.Palette.gold.opacity(0.3) :
                        item.color.opacity(0.8)
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            item.isPurchased ?
                            PlinkoTheme.Palette.gold :
                                item.color,
                            lineWidth: 3
                        )
                )
                .shadow(color: item.color.opacity(0.5), radius: 10)
            }
            .disabled(item.isPurchased || !item.isAvailable || game.playerCoins < item.price)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PlinkoTheme.Gradient.gameFieldBackground)
    }
    
    private func getEffectDetails(for item: ShopItem) -> String {
        switch item.name {
        case "Score Multiplier":
            return "• Activates for next 5 balls\n• All points are doubled\n• Perfect timing for high-value slots\n• Visual: Ball glows red"
            
        case "Magnetic Ball":
            return "• Ball curves toward highest slots\n• Magnetic force: 0.3 strength\n• Duration: 20 seconds\n• Increases accuracy significantly\n• Visual: Blue trail effect"
            
        case "Shield Ball":
            return "• Ignores all pin collisions\n• Flies straight to slots\n• Guaranteed slot hit\n• Visual: Green shield around ball"
            
        case "Pin Destroyer":
            return "• Removes every 2nd pin\n• Duration: 20 seconds\n• Makes field much easier\n• Visual: Pins disappear with animation"
            
        case "Double Points":
            return "• All slots give 2x points\n• Duration: 20 seconds\n• Works with other multipliers\n• Visual: Slots glow blue"
            
        case "Slot Shuffle":
            return "• Randomizes slot positions\n• Instant effect\n• Adds challenge and excitement\n• Visual: Slots rearrange with animation"
            
        case "Triple Ball":
            return "• Launches 3 balls simultaneously\n• Each ball can score points\n• Triple scoring potential\n• Visual: 3 balls with slight offset"
            
        case "Six Ball":
            return "• Launches 6 balls at once\n• Maximum scoring potential\n• Can earn 500+ points\n• Visual: Fan pattern launch"
            
        case "Neon Theme":
            return "• Glowing effects on all elements\n• Pins have neon glow\n• Slots pulse with colors\n• Visual: Bright trail effects"
            
        default:
            return "Special effect details coming soon!"
        }
    }
    
    private func getBonusIcon(for bonusName: String) -> String {
        switch bonusName {
        case "Score Multiplier": return "star.circle.fill"
        case "Magnetic Ball": return "magnet.fill"
        case "Shield Ball": return "shield.fill"
        case "Pin Destroyer": return "trash.circle.fill"
        case "Double Points": return "2.circle.fill"
        case "Slot Shuffle": return "shuffle.circle.fill"
        case "Triple Ball": return "3.circle.fill"
        case "Six Ball": return "6.circle.fill"
        case "Neon Theme": return "lightbulb.fill"
        default: return "star.fill"
        }
    }
    
    private func getShopButtonText() -> String {
        if let activeBonus = game.currentActiveBonus {
            return activeBonus
        } else {
            return "Shop"
        }
    }
    
    // MARK: - Daily Bonus Screen
    
    private var dailyBonusScreen: some View {
        VStack(spacing: 30) {
            Text("Daily Bonus")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(PlinkoTheme.Palette.gold)
                .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                if game.isBonusAvailable {
                    VStack(spacing: 15) {
                        Text("    🎁 Bonus Available!    ")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.gold)
                        
                        Text("    Spin to get bonus points!    ")
                            .font(.body)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                        
                        Button(action: {
                            game.claimBonus()
                        }) {
                            HStack {
                                if game.isSpinning {
                                    spinningWheelView
                                } else {
                                    Image(systemName: "gift.fill")
                                    Text("Claim Points")
                                }
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.textPrimary)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(PlinkoTheme.Palette.gold)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(PlinkoTheme.Palette.neonPink, lineWidth: 2)
                            )
                            .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
                        }
                        .disabled(game.isSpinning)
                    }
                    
                } else {
                    VStack(spacing: 15) {
                        Text("    ⏰ Next Bonus In    ")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.textPrimary)
                        
                        Text(game.formatTimeRemaining(game.timeUntilNextBonus))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.electricBlue)
                            .monospacedDigit()
                        
                        Text("    Come back later for your next bonus points!    ")
                            .font(.body)
                            .foregroundColor(PlinkoTheme.Palette.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if game.showSpinResult {
                    VStack(spacing: 10) {
                        Text("🎉 Congratulations!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlinkoTheme.Palette.gold)
                        
                        Text(game.spinResult)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(PlinkoTheme.Palette.spherePrimary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(PlinkoTheme.Palette.gold, lineWidth: 2)
                            )
                    )
                    .shadow(color: PlinkoTheme.Shadow.gold, radius: 10)
                }
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(PlinkoTheme.Palette.gold.opacity(0.3), lineWidth: 2)
                    )
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
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
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(PlinkoTheme.Gradient.buttonPrimary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PlinkoTheme.Palette.spherePrimary, lineWidth: 2)
                )
                .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 8)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PlinkoTheme.Gradient.gameFieldBackground)
    }
    
    // MARK: - Spinning Wheel Animation
    
    private var spinningWheelView: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.yellow.opacity(0.8),
                            Color.orange.opacity(0.6),
                            Color.red.opacity(0.4),
                            Color.purple.opacity(0.6),
                            Color.blue.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(game.isSpinning ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                    value: game.isSpinning
                )
            
            // Inner spinning circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.yellow.opacity(0.7),
                            Color.orange.opacity(0.5),
                            Color.red.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(game.isSpinning ? -360 : 0))
                .animation(
                    Animation.linear(duration: 0.8)
                        .repeatForever(autoreverses: false),
                    value: game.isSpinning
                )
            
            // Center gift icon
            Image(systemName: "gift.fill")
                .font(.title2)
                .foregroundColor(.white)
                .scaleEffect(game.isSpinning ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: game.isSpinning
                )
        }
        .shadow(color: Color.yellow.opacity(0.6), radius: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
