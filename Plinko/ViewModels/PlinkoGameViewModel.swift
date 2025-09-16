//
//  PlinkoGameViewModel.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import SwiftUI
import Combine

/*
 Screen height: 957 тоді  let pinY = slotYPosition - 230 //
 Screen height: 874 тоді  let pinY = slotYPosition - 220 //
 Screen height: 667  тоді  let pinY = slotYPosition - 180 //
*/

// MARK: - Game State
class PlinkoGameViewModel: ObservableObject {
    @Published var ball: Ball?
    @Published var score: Int = 0
    @Published var isPlaying: Bool = false
    @Published var totalGames: Int = 0
    @Published var bestScore: Int = 0
    @Published var showCelebration: Bool = false
    
    // Навігація між екранами
    @Published var currentScreen: GameScreen = .game
    
    // Налаштування фізики
    @Published var bounceStrength: BounceStrength = .medium
    @Published var gravityStrength: GravityStrength = .medium
    
    // Рейтинг
    @Published var playerName: String = ""
    @Published var savedScores: [PlayerScore] = []
    
    // Статистика гравця
    @Published var totalScore: Int = 0
    @Published var averageScore: Double = 0.0
    @Published var efficiencyCoefficient: Double = 0.0
    
    // Поп-ап для збереження
    @Published var showSaveConfirmation: Bool = false
    
    private var pins: [Pin] = []
    private var slots: [Slot] = []
    private var gameTimer: Timer?
    private var celebrationTimer: Timer?
    private var collisionCount: Int = 0
    private var lastPosition: CGPoint = .zero
    private var gameStartTime: Date = Date()
    
    var gameWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // Горизонтальні відступи
    }
    var gameHeight: CGFloat {
        UIScreen.main.bounds.height - 300 // Вертикальні відступи для заголовка, статистики та кнопок
    }
    
    init() {
        setupGame()
        loadScoresFromUserDefaults()
        // НЕ завантажуємо статистику гравця при запуску - вона має бути скинута
        resetPlayerStatistics()
    }
    
    private func setupGame() {
        // Очищуємо масив пінів
        pins.removeAll()
        
        // Створюємо піни в шаховому порядку з динамічною відстанню
        // Використовуємо той же підхід центрування що і для слотів (відносно екрану)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pinSpacing: CGFloat = screenWidth * 0.075 // 7.5% від ширини екрану (як оригінально)
        let slotYPosition = gameHeight * 0.70 // Позиція слотів
        
        // Адаптивна відстань між пінами та слотами залежно від висоти екрану
        let pinOffset: CGFloat
        switch screenHeight {
        case 667...700:    // iPhone SE та подібні
            pinOffset = 180
        case 700...900:    // iPhone стандартні розміри
            pinOffset = 220
        case 900...1000:   // iPhone Plus/Max та iPad
            pinOffset = 230
        default:           // За замовчуванням для невідомих розмірів
            pinOffset = 220
        }
        
        let pinY = slotYPosition - pinOffset
        let rows = 8
        
        print("📌 Pin setup:")
        print("📌 Screen width: \(screenWidth)")
        print("📌 Screen height: \(screenHeight)")
        print("📌 Game width: \(gameWidth)")
        print("📌 Game height: \(gameHeight)")
        print("📌 Pin spacing (7.5%): \(pinSpacing)")
        print("📌 Pin radius: \(screenWidth * 0.01)")
        print("📌 Ball radius: \(screenWidth * 0.015)")
        print("📌 Slot Y: \(slotYPosition)")
        print("📌 Pin offset: \(pinOffset)")
        print("📌 Pin Y: \(pinY)")
        
        for row in 0..<rows {
            let y = pinY + CGFloat(row) * pinSpacing
            let pinsInRow = row + 3
            
            // Центрування рядка відносно екрану (як оригінально для слотів)
            let totalRowWidth = CGFloat(pinsInRow - 1) * pinSpacing
            let startX = (screenWidth - totalRowWidth) / 2 // Центрування по екрану
            
            print("📌 Row \(row): pins=\(pinsInRow), y=\(y), startX=\(startX)")
            
            for col in 0..<pinsInRow {
                let x = startX + CGFloat(col) * pinSpacing
                pins.append(Pin(position: CGPoint(x: x, y: y)))
                print("📌 Pin \(row)-\(col): x=\(x), y=\(y)")
            }
        }
        
        // Очищуємо масив слотів
        slots.removeAll()
        
        // Створюємо слоти внизу з відсотковими розрахунками відносно екрану (оригінальний підхід)
        let totalSlotWidth = screenWidth * 0.8 // 80% від ширини екрану
        let slotSpacing: CGFloat = 5 // Відстань між слотами 5 пікселів
        let slotWidth = (totalSlotWidth - CGFloat(9) * slotSpacing) / 10 // Ширина одного слота з урахуванням відступів
        let slotHeight: CGFloat = min(gameHeight * 0.08, 30) // 8% від висоти ігрового поля
        let slotY = gameHeight * 0.75 // 80% від висоти ігрового поля (20% відступ від низу)
        let startSlotX = (screenWidth - totalSlotWidth) / 2 // Центрування по екрану
        
        print("📐 Screen width: \(screenWidth)")
        print("📐 Game width: \(gameWidth)")
        print("📐 Total slot width (80%): \(totalSlotWidth)")
        print("📐 Individual slot width: \(slotWidth)")
        print("📐 Start slot X (centered): \(startSlotX)")
        print("📐 Slot Y position: \(slotY)")
        
        let slotPoints = [100, 50, 20, 10, 5, 5, 10, 20, 50, 100]
        let slotColors: [Color] = [.red, .orange, .yellow, .green, .blue, .blue, .green, .yellow, .orange, .red]
        
        for i in 0..<10 {
            let x = startSlotX + CGFloat(i) * (slotWidth + slotSpacing)
            let rect = CGRect(x: x, y: slotY, width: slotWidth, height: slotHeight)
            slots.append(Slot(rect: rect, points: slotPoints[i], color: slotColors[i]))
            print("📐 Slot \(i): x=\(x), width=\(slotWidth), spacing=\(slotSpacing), rect=\(rect)")
        }
    }
    
    func startGame() {
        guard !isPlaying else { return }
        
        isPlaying = true
        score = 0
        showCelebration = false
        collisionCount = 0
        gameStartTime = Date()
        
        // Початкова позиція кульки по центру екрану з правильною швидкістю
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
        
        // Перевіряємо, чи кулька застряла
        let distanceMoved = sqrt(pow(currentBall.position.x - lastPosition.x, 2) + 
                               pow(currentBall.position.y - lastPosition.y, 2))
        
        if distanceMoved < 0.5 {
            collisionCount += 1
            if collisionCount > 30 { // Якщо кулька не рухається 30 кадрів
                // Примусово змінюємо позицію кульки
                currentBall.position.y += 5
                currentBall.velocity.dy = 2
                collisionCount = 0
            }
        } else {
            collisionCount = 0
        }
        
        lastPosition = currentBall.position
        
        // Додаємо гравітацію до вертикальної швидкості
        let gravity: CGFloat = gravityStrength.value
        currentBall.velocity.dy += gravity
        
        // Додаємо опір повітря (невелике уповільнення)
        let airResistance: CGFloat = 0.998
        currentBall.velocity.dx *= airResistance
        currentBall.velocity.dy *= airResistance
        
        // Оновлюємо позицію кульки
        currentBall.position.x += currentBall.velocity.dx
        currentBall.position.y += currentBall.velocity.dy
        
        // Перевіряємо зіткнення зі стінами
        if currentBall.position.x - currentBall.radius <= 0 || 
           currentBall.position.x + currentBall.radius >= gameWidth {
            currentBall.velocity.dx *= -0.8
            currentBall.position.x = max(currentBall.radius, 
                                       min(gameWidth - currentBall.radius, currentBall.position.x))
        }
        
        // Перевіряємо зіткнення з пінами
        for pin in pins {
            let distance = sqrt(pow(currentBall.position.x - pin.position.x, 2) + 
                              pow(currentBall.position.y - pin.position.y, 2))
            
            if distance < currentBall.radius + pin.radius {
                // Відтворюємо звук зіткнення
                SoundManager.shared.playPinHit()
                
                // Розраховуємо відбиття з урахуванням гравітації
                let angle = atan2(currentBall.position.y - pin.position.y, 
                                currentBall.position.x - pin.position.x)
                let speed = sqrt(pow(currentBall.velocity.dx, 2) + pow(currentBall.velocity.dy, 2))
                
                // Відбиття з втратою енергії та збереженням мінімальної швидкості
                let bounceSpeed = max(speed * bounceStrength.multiplier, 1.5) // Використовуємо налаштування відбиття
                currentBall.velocity.dx = cos(angle) * bounceSpeed
                currentBall.velocity.dy = sin(angle) * bounceSpeed
                
                // Відштовхуємо кульку від піна з додатковим відступом
                let overlap = currentBall.radius + pin.radius - distance + 2 // Додатковий відступ
                currentBall.position.x += cos(angle) * overlap
                currentBall.position.y += sin(angle) * overlap
                
                // Якщо кулька рухається занадто повільно, додаємо імпульс
                if speed < 2.0 {
                    currentBall.velocity.dy += 1.0 // Додаємо вертикальний імпульс
                }
            }
        }
        
        // Перевіряємо попадання в слоти
        for slot in slots {
            if slot.rect.contains(currentBall.position) {
                score += slot.points
                totalScore += slot.points  // Додаємо до загального рахунку
                SoundManager.shared.playSlotHit()
                
                // Оновлюємо статистику
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
        
        // Перевіряємо, чи кулька вийшла за межі
        if currentBall.position.y > gameHeight {
            endGame()
            return
        }
        
        // Перевіряємо таймаут гри (максимум 30 секунд)
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
        
        // Оновлюємо статистику після кожної гри
        updatePlayerStatistics()
    }
    
    private func startCelebration() {
        celebrationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.showCelebration = false
        }
    }
    
    func resetStats() {
        resetPlayerStatistics()
        // Зберігаємо скинуту статистику в UserDefaults
        savePlayerStatistics()
    }
    
    func getPins() -> [Pin] { pins }
    func getSlots() -> [Slot] { slots }
    
    // MARK: - Navigation Methods
    func showSettings() {
        currentScreen = .settings
    }
    
    func showRating() {
        currentScreen = .rating
    }
    
    func showGame() {
        currentScreen = .game
    }
    
    // MARK: - Rating Methods
    func saveScore() {
        guard !playerName.isEmpty && score > 0 else { return }
        
        // Показуємо поп-ап з попередженням
        showSaveConfirmation = true
    }
    
    func confirmSaveScore() {
        // Рахунок вже додано до totalScore під час гри
        
        // Розраховуємо коефіцієнт ефективності ПЕРЕД збереженням
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
        savedScores.sort { $0.efficiencyCoefficient > $1.efficiencyCoefficient } // Сортуємо за ефективністю
        
        // Зберігаємо тільки топ-10 результатів
        if savedScores.count > 10 {
            savedScores = Array(savedScores.prefix(10))
        }
        
        // Зберігаємо в UserDefaults
        saveScoresToUserDefaults()
        
        // Скидаємо ВСЕ на нулі
        resetPlayerStatistics()
        savePlayerStatistics()
        
        // Закриваємо поп-ап
        showSaveConfirmation = false
    }
    
    private func calculateEfficiencyCoefficient() -> Double {
        // Вираховуємо середній рахунок
        let avgScore = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
        
        // Вираховуємо коефіцієнт корисної загальної суми
        // Формула: (bestScore * 0.4) + (averageScore * 0.3) + (totalGames * 0.3)
        return (Double(bestScore) * 0.4) + (avgScore * 0.3) + (Double(totalGames) * 0.3)
    }
    
    func cancelSaveScore() {
        showSaveConfirmation = false
    }
    
    
    private func updatePlayerStatistics() {
        // Вираховуємо середній рахунок
        averageScore = totalGames > 0 ? Double(totalScore) / Double(totalGames) : 0.0
        
        // Вираховуємо коефіцієнт корисної загальної суми
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
    }
}

// MARK: - Game Screen Enum
enum GameScreen {
    case game
    case settings
    case rating
}

// MARK: - Player Score Model
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

// MARK: - Physics Settings Enums
enum BounceStrength: String, CaseIterable {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    
    var multiplier: CGFloat {
        switch self {
        case .weak: return 0.42  // 0.6 * 0.7 (зменшуємо на 30%)
        case .medium: return 0.56  // 0.8 * 0.7 (зменшуємо на 30%)
        case .strong: return 0.7  // 1.0 * 0.7 (зменшуємо на 30%)
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
