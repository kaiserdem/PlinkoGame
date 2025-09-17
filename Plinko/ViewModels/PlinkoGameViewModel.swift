
import SwiftUI
import Combine

class PlinkoGameViewModel: ObservableObject {
    @Published var ball: Ball?
    @Published var score: Int = 0
    @Published var isPlaying: Bool = false
    @Published var totalGames: Int = 0
    @Published var bestScore: Int = 0
    @Published var showCelebration: Bool = false
    
    @Published var currentScreen: GameScreen = .game
    @Published var bounceStrength: BounceStrength = .medium
    @Published var gravityStrength: GravityStrength = .medium
    @Published var playerName: String = ""
    @Published var savedScores: [PlayerScore] = []
    @Published var totalScore: Int = 0
    @Published var averageScore: Double = 0.0
    @Published var efficiencyCoefficient: Double = 0.0
    @Published var showSaveConfirmation: Bool = false
    @Published var showResetConfirmation: Bool = false
    @Published var shopItems: [ShopItem] = []
    @Published var playerCoins: Int = 0
    @Published var selectedBonusItem: ShopItem?
    @Published var currentActiveBonus: String? = nil
    @Published var scoreMultiplierBallsLeft: Int = 0
    
    var purchasedBonusesCount: Int {
        shopItems.filter { $0.isPurchased }.count
    }
    
    private var pins: [Pin] = []
    private var slots: [Slot] = []
    private var gameTimer: Timer?
    private var celebrationTimer: Timer?
    private var collisionCount: Int = 0
    private var lastPosition: CGPoint = .zero
    private var gameStartTime: Date = Date()
    
    var gameWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }
    var gameHeight: CGFloat {
        UIScreen.main.bounds.height - 300
    }
    
    init() {
        setupGame()
        loadScoresFromUserDefaults()
        resetPlayerStatistics()
        setupShopItems()
        playerCoins = 500
    }
    
    private func setupGame() {
        pins.removeAll()
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pinSpacing: CGFloat = screenWidth * 0.075
        let slotYPosition = gameHeight * 0.70
        
        let pinOffset: CGFloat
        switch screenHeight {
        case 667...700:
            pinOffset = 180
        case 700...900:
            pinOffset = 220
        case 900...1000:
            pinOffset = 230
        default:
            pinOffset = 220
        }
        
        let pinY = slotYPosition - pinOffset
        let rows = 8
        
        for row in 0..<rows {
            let y = pinY + CGFloat(row) * pinSpacing
            let pinsInRow = row + 3
            
            let totalRowWidth = CGFloat(pinsInRow - 1) * pinSpacing
            let startX = (screenWidth - totalRowWidth) / 2
            
            for col in 0..<pinsInRow {
                let x = startX + CGFloat(col) * pinSpacing
                pins.append(Pin(position: CGPoint(x: x, y: y)))
            }
        }
        
        slots.removeAll()
        
        let totalSlotWidth = screenWidth * 0.8
        let slotSpacing: CGFloat = 5
        let slotWidth = (totalSlotWidth - CGFloat(9) * slotSpacing) / 10
        let slotHeight: CGFloat = min(gameHeight * 0.08, 30)
        let slotY = gameHeight * 0.75
        let startSlotX = (screenWidth - totalSlotWidth) / 2
        
        let slotPoints = [100, 50, 20, 10, 5, 5, 10, 20, 50, 100]
        let slotColors: [Color] = [.red, .orange, .yellow, .green, .blue, .blue, .green, .yellow, .orange, .red]
        
        for i in 0..<10 {
            let x = startSlotX + CGFloat(i) * (slotWidth + slotSpacing)
            let rect = CGRect(x: x, y: slotY, width: slotWidth, height: slotHeight)
            slots.append(Slot(rect: rect, points: slotPoints[i], color: slotColors[i]))
        }
    }
    
    func startGame() {
        guard !isPlaying else { return }
        
        isPlaying = true
        score = 0
        showCelebration = false
        collisionCount = 0
        gameStartTime = Date()
        
        let screenWidth = UIScreen.main.bounds.width
        ball = Ball(
            position: CGPoint(x: screenWidth / 2, y: 30),
            velocity: CGVector(dx: Double.random(in: -0.5...0.5), dy: Double.random(in: 1.0...2.0))
        )
        
        startGameLoop()
    }
    
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func updateGame() {
        guard var currentBall = ball else { return }
        
        let distanceMoved = sqrt(pow(currentBall.position.x - lastPosition.x, 2) + 
                               pow(currentBall.position.y - lastPosition.y, 2))
        
        if distanceMoved < 0.5 {
            collisionCount += 1
            if collisionCount > 30 {
                currentBall.position.y += 5
                currentBall.velocity.dy = 2
                collisionCount = 0
            }
        } else {
            collisionCount = 0
        }
        
        lastPosition = currentBall.position
        
        let gravity: CGFloat = gravityStrength.value
        currentBall.velocity.dy += gravity
        
        let airResistance: CGFloat = 0.998
        currentBall.velocity.dx *= airResistance
        currentBall.velocity.dy *= airResistance
        
        currentBall.position.x += currentBall.velocity.dx
        currentBall.position.y += currentBall.velocity.dy
        
        // Застосовуємо Magnetic Ball ефект
        if currentActiveBonus == "Magnetic Ball" {
            applyMagneticEffect(to: &currentBall)
        }
        
        if currentBall.position.x - currentBall.radius <= 0 || 
           currentBall.position.x + currentBall.radius >= gameWidth {
            currentBall.velocity.dx *= -0.8
            currentBall.position.x = max(currentBall.radius, 
                                       min(gameWidth - currentBall.radius, currentBall.position.x))
        }
        
        for pin in pins {
            let distance = sqrt(pow(currentBall.position.x - pin.position.x, 2) + 
                              pow(currentBall.position.y - pin.position.y, 2))
            
            if distance < currentBall.radius + pin.radius {
                SoundManager.shared.playPinHit()
                
                let angle = atan2(currentBall.position.y - pin.position.y, 
                                currentBall.position.x - pin.position.x)
                let speed = sqrt(pow(currentBall.velocity.dx, 2) + pow(currentBall.velocity.dy, 2))
                
                let bounceSpeed = max(speed * bounceStrength.multiplier, 1.5)
                currentBall.velocity.dx = cos(angle) * bounceSpeed
                currentBall.velocity.dy = sin(angle) * bounceSpeed
                
                let overlap = currentBall.radius + pin.radius - distance + 2
                currentBall.position.x += cos(angle) * overlap
                currentBall.position.y += sin(angle) * overlap
                
                if speed < 2.0 {
                    currentBall.velocity.dy += 1.0
                }
            }
        }
        
        for slot in slots {
            if slot.rect.contains(currentBall.position) {
                var pointsEarned = slot.points
                
                // Застосовуємо Score Multiplier якщо активний
                if currentActiveBonus == "Score Multiplier" && scoreMultiplierBallsLeft > 0 {
                    pointsEarned *= 2
                    scoreMultiplierBallsLeft -= 1
                    
                    // Якщо закінчилися м'ячі для мультиплікатора, деактивуємо бонус
                    if scoreMultiplierBallsLeft == 0 {
                        currentActiveBonus = nil
                        // Повертаємо бонус в магазин після використання
                        returnBonusToShop("Score Multiplier")
                    }
                }
                
                score += pointsEarned
                totalScore += pointsEarned
                earnCoins(pointsEarned)
                SoundManager.shared.playSlotHit()
                
                totalGames += 1
                if score > bestScore {
                    bestScore = score
                    showCelebration = true
                    startCelebration()
                }
                
                endGame()
                return
            }
        }
        
        if currentBall.position.y > gameHeight {
            endGame()
            return
        }
        
        if Date().timeIntervalSince(gameStartTime) > 30 {
            endGame()
            return
        }
        
        ball = currentBall
    }
    
    private func endGame() {
        isPlaying = false
        gameTimer?.invalidate()
        gameTimer = nil
        ball = nil
        
        updatePlayerStatistics()
    }
    
    private func startCelebration() {
        celebrationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.showCelebration = false
        }
    }
    
    func resetStats() {
        resetPlayerStatistics()
        savePlayerStatistics()
    }
    
    func showResetAllConfirmation() {
        showResetConfirmation = true
    }
    
    func confirmResetAll() {
        resetPlayerStatistics()
        savedScores.removeAll()
        savePlayerStatistics()
        saveScoresToUserDefaults()
        showResetConfirmation = false
    }
    
    func cancelResetAll() {
        showResetConfirmation = false
    }
    
    func getPins() -> [Pin] { pins }
    func getSlots() -> [Slot] { slots }
    
    func showSettings() {
        currentScreen = .settings
    }
    
    func showRating() {
        currentScreen = .rating
    }
    
    func showGame() {
        currentScreen = .game
    }
    
    func showShop() {
        currentScreen = .shop
    }
    
    func showBonuses() {
        currentScreen = .bonuses
    }
    
    func showBonusDetail(_ item: ShopItem) {
        selectedBonusItem = item
        currentScreen = .bonusDetail(item)
    }
    
    func backToShop() {
        currentScreen = .shop
        selectedBonusItem = nil
    }
    
    func saveScore() {
        guard !playerName.isEmpty && score > 0 else { return }
        
        showSaveConfirmation = true
    }
    
    func confirmSaveScore() {
        let currentEfficiency = calculateEfficiencyCoefficient()
        
        let newScore = PlayerScore(
            name: playerName, 
            score: score, 
            totalScore: totalScore, 
            bestScore: bestScore, 
            totalGames: totalGames, 
            efficiencyCoefficient: currentEfficiency, 
            date: Date()
        )
        savedScores.append(newScore)
        savedScores.sort { $0.efficiencyCoefficient > $1.efficiencyCoefficient }
        
        if savedScores.count > 10 {
            savedScores = Array(savedScores.prefix(10))
        }
        
        saveScoresToUserDefaults()
        resetPlayerStatistics()
        savePlayerStatistics()
        showSaveConfirmation = false
    }
    
    private func calculateEfficiencyCoefficient() -> Double {
        let avgScore = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
        return (Double(bestScore) * 0.4) + (avgScore * 0.3) + (Double(totalGames) * 0.3)
    }
    
    func cancelSaveScore() {
        showSaveConfirmation = false
    }
    
    
    private func updatePlayerStatistics() {
        averageScore = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
        efficiencyCoefficient = calculateEfficiencyCoefficient()
    }
    
    private func saveScoresToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedScores) {
            UserDefaults.standard.set(encoded, forKey: "SavedScores")
        }
    }
    
    func loadScoresFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "SavedScores"),
           let decoded = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            savedScores = decoded
        }
    }
    
    private func savePlayerStatistics() {
        let statistics: [String: Any] = [
            "totalScore": totalScore,
            "averageScore": averageScore,
            "efficiencyCoefficient": efficiencyCoefficient,
            "bestScore": bestScore,
            "totalGames": totalGames
        ]
        UserDefaults.standard.set(statistics, forKey: "PlayerStatistics")
    }
    
    func loadPlayerStatistics() {
        if let statistics = UserDefaults.standard.dictionary(forKey: "PlayerStatistics") {
            totalScore = statistics["totalScore"] as? Int ?? 0
            averageScore = statistics["averageScore"] as? Double ?? 0.0
            efficiencyCoefficient = statistics["efficiencyCoefficient"] as? Double ?? 0.0
            bestScore = statistics["bestScore"] as? Int ?? 0
            totalGames = statistics["totalGames"] as? Int ?? 0
        }
    }
    
    private func resetPlayerStatistics() {
        totalScore = 0
        averageScore = 0.0
        efficiencyCoefficient = 0.0
        bestScore = 0
        totalGames = 0
        score = 0
        showCelebration = false
        playerCoins = 0
    }
    
    // MARK: - Shop Methods
    
    private func setupShopItems() {
        shopItems = [
            ShopItem(name: "Score Multiplier", description: "Doubles points for next 5 balls. Perfect for maximizing your score when you're on a hot streak!", price: 200, icon: "multiply.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .red),
            ShopItem(name: "Magnetic Ball", description: "Attracts to highest value slots for 20 seconds. The ball will curve towards the most valuable slots automatically!", price: 300, icon: "magnet.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .blue),
            ShopItem(name: "Shield Ball", description: "Ignores pin collisions and flies straight down. Guaranteed to reach a slot without bouncing off pins!", price: 400, icon: "shield.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .green),
            ShopItem(name: "Pin Destroyer", description: "Removes every second pin for 20 seconds. Makes the field much easier to navigate and score!", price: 350, icon: "trash.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .red),
            ShopItem(name: "Double Points", description: "All slots give 2x points for 20 seconds. Every hit becomes twice as valuable!", price: 400, icon: "2.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .blue),
            ShopItem(name: "Slot Shuffle", description: "Randomizes all slot positions. Adds excitement and challenge by changing the layout!", price: 300, icon: "shuffle.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .green),
            ShopItem(name: "Triple Ball", description: "Launches 3 balls instead of 1. Triple your chances of scoring big points!", price: 500, icon: "3.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .yellow),
            ShopItem(name: "Six Ball", description: "Launches 6 balls at once! Maximum scoring potential - can earn hundreds of points!", price: 800, icon: "6.circle.fill", type: .powerUp, isPurchased: false, isAvailable: true, color: .orange),
            ShopItem(name: "Neon Theme", description: "Adds glowing neon effects to all game elements. Pure visual enhancement for style!", price: 250, icon: "lightbulb.fill", type: .cosmetic, isPurchased: false, isAvailable: true, color: .purple)
        ]
    }
    
    func purchaseItem(_ item: ShopItem) {
        guard !item.isPurchased && item.isAvailable && playerCoins >= item.price else { return }
        
        playerCoins -= item.price
        
        if let index = shopItems.firstIndex(where: { $0.id == item.id }) {
            shopItems[index] = ShopItem(
                name: item.name,
                description: item.description,
                price: item.price,
                icon: item.icon,
                type: item.type,
                isPurchased: true,
                isAvailable: item.isAvailable,
                color: item.color
            )
        }
        
        // Автоматично активуємо бонус після покупки
        activateBonus(item.name)
        
        // Повертаємося на головний екран
        currentScreen = .game
    }
    
    func earnCoins(_ amount: Int) {
        playerCoins += amount
    }
    
    func activateBonus(_ bonusName: String) {
        currentActiveBonus = bonusName
        
        switch bonusName {
        case "Score Multiplier":
            scoreMultiplierBallsLeft = 5 // 5 м'ячів з подвоєними очками
        case "Magnetic Ball":
            // Magnetic Ball працює 20 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
                self.currentActiveBonus = nil
                // Повертаємо бонус в магазин після використання
                self.returnBonusToShop(bonusName)
            }
        default:
            // Простий таймер для інших бонусів - через 5 секунд бонус закінчується
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.currentActiveBonus = nil
                // Повертаємо бонус в магазин після використання
                self.returnBonusToShop(bonusName)
            }
        }
    }
    
    private func applyMagneticEffect(to ball: inout Ball) {
        // Знаходимо слоти з найвищими очками (100 очок)
        let highValueSlots = slots.filter { $0.points == 100 }
        
        if !highValueSlots.isEmpty {
            // Знаходимо найближчий високоцінний слот
            var closestSlot: Slot?
            var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            
            for slot in highValueSlots {
                let distance = sqrt(pow(ball.position.x - slot.rect.midX, 2) + 
                                  pow(ball.position.y - slot.rect.midY, 2))
                if distance < minDistance {
                    minDistance = distance
                    closestSlot = slot
                }
            }
            
            if let targetSlot = closestSlot {
                // Розраховуємо напрямок до цільового слоту
                let dx = targetSlot.rect.midX - ball.position.x
                let dy = targetSlot.rect.midY - ball.position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance > 0 {
                    // Сила магніту (0.3 як зазначено в описі)
                    let magneticForce: CGFloat = 0.3
                    let normalizedDx = dx / distance
                    let normalizedDy = dy / distance
                    
                    // Застосовуємо магнітну силу до швидкості м'яча
                    ball.velocity.dx += normalizedDx * magneticForce
                    ball.velocity.dy += normalizedDy * magneticForce
                }
            }
        }
    }
    
    private func returnBonusToShop(_ bonusName: String) {
        if let index = shopItems.firstIndex(where: { $0.name == bonusName }) {
            shopItems[index] = ShopItem(
                name: shopItems[index].name,
                description: shopItems[index].description,
                price: shopItems[index].price,
                icon: shopItems[index].icon,
                type: shopItems[index].type,
                isPurchased: false, // Повертаємо як не куплений
                isAvailable: shopItems[index].isAvailable,
                color: shopItems[index].color
            )
        }
    }
}

enum GameScreen {
    case game
    case settings
    case rating
    case shop
    case bonuses
    case bonusDetail(ShopItem)
}

struct PlayerScore: Codable, Identifiable {
    let id: UUID
    let name: String
    let score: Int
    let totalScore: Int
    let bestScore: Int
    let totalGames: Int
    let efficiencyCoefficient: Double
    let date: Date
    
    init(name: String, score: Int, totalScore: Int, bestScore: Int, totalGames: Int, efficiencyCoefficient: Double, date: Date) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.totalScore = totalScore
        self.bestScore = bestScore
        self.totalGames = totalGames
        self.efficiencyCoefficient = efficiencyCoefficient
        self.date = date
    }
}

enum BounceStrength: String, CaseIterable {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    
    var multiplier: CGFloat {
        switch self {
        case .weak: return 0.42
        case .medium: return 0.56
        case .strong: return 0.7
        }
    }
}

enum GravityStrength: String, CaseIterable {
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"
    
    var value: CGFloat {
        switch self {
        case .light: return 0.2
        case .medium: return 0.3
        case .heavy: return 0.5
        }
    }
}

// MARK: - Shop Models

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Int
    let icon: String
    let type: ShopItemType
    let isPurchased: Bool
    let isAvailable: Bool
    let color: Color
}

enum ShopItemType {
    case powerUp
    case ballType
    case cosmetic
    case upgrade
}
