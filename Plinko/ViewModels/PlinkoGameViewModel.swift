//
//  PlinkoGameViewModel.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import SwiftUI
import Combine

// MARK: - Game State
class PlinkoGameViewModel: ObservableObject {
    @Published var ball: Ball?
    @Published var score: Int = 0
    @Published var isPlaying: Bool = false
    @Published var totalGames: Int = 0
    @Published var bestScore: Int = 0
    @Published var showCelebration: Bool = false
    
    private var pins: [Pin] = []
    private var slots: [Slot] = []
    private var gameTimer: Timer?
    private var celebrationTimer: Timer?
    private var collisionCount: Int = 0
    private var lastPosition: CGPoint = .zero
    private var gameStartTime: Date = Date()
    
    var gameWidth: CGFloat = UIScreen.main.bounds.width - 40
    var gameHeight: CGFloat = UIScreen.main.bounds.height - 300
    
    init() {
        setupGame()
    }
    
    private func setupGame() {
        // Очищуємо масив пінів
        pins.removeAll()
        
        // Створюємо піни в шаховому порядку з відсотковими розрахунками
        let pinSpacing: CGFloat = min(gameWidth / 12, 30)
        let startY: CGFloat = gameHeight * 0.15 // 15% від висоти ігрового поля
        let rows = 8
        
        for row in 0..<rows {
            let y = startY + CGFloat(row) * pinSpacing
            let pinsInRow = row + 3
            
            // Центрування рядка з відсотковими розрахунками
            let totalRowWidth = CGFloat(pinsInRow - 1) * pinSpacing
            let startX = gameWidth * 0.1 + (gameWidth * 0.8 - totalRowWidth) / 2
            
            for col in 0..<pinsInRow {
                let x = startX + CGFloat(col) * pinSpacing
                pins.append(Pin(position: CGPoint(x: x, y: y)))
            }
        }
        
        // Очищуємо масив слотів
        slots.removeAll()
        
        // Створюємо слоти внизу з відсотковими розрахунками
        let screenWidth = UIScreen.main.bounds.width
        let totalSlotWidth = screenWidth * 0.8 // 80% від ширини екрану
        let slotWidth = totalSlotWidth / 10 // Ширина одного слота (10 слотів)
        let slotHeight: CGFloat = min(gameHeight * 0.08, 40) // 8% від висоти
        let slotY = gameHeight * 0.85 // 80% від висоти ігрового поля (20% відступ від низу)
        let slotSpacing: CGFloat = 2 // Без відступів між слотами
        let startSlotX = (screenWidth - totalSlotWidth) / 2 // Центрування по екрану
        
        print("📱 Screen width: \(screenWidth)")
        print("📐 Total slot width (80%): \(totalSlotWidth)")
        print("📐 Individual slot width: \(slotWidth)")
        print("📐 Start slot X (centered): \(startSlotX)")
        print("📐 Slot Y position: \(slotY)")
        
        let slotPoints = [100, 50, 20, 10, 5, 5, 10, 20, 50, 100]
        let slotColors: [Color] = [.red, .orange, .yellow, .green, .blue, .blue, .green, .yellow, .orange, .red]
        
        for i in 0..<10 {
            let x = startSlotX + CGFloat(i) * slotWidth
            let rect = CGRect(x: x, y: slotY, width: slotWidth, height: slotHeight)
            slots.append(Slot(rect: rect, points: slotPoints[i], color: slotColors[i]))
            print("📐 Slot \(i): x=\(x), width=\(slotWidth), rect=\(rect)")
        }
    }
    
    func startGame() {
        guard !isPlaying else { return }
        
        isPlaying = true
        score = 0
        showCelebration = false
        collisionCount = 0
        gameStartTime = Date()
        
        // Початкова позиція кульки з меншою вертикальною швидкістю (гравітація прискорить)
        ball = Ball(
            position: CGPoint(x: gameWidth / 2, y: 20),
            velocity: CGVector(dx: Double.random(in: -2...2), dy: Double.random(in: 0.5...1.5))
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
        let gravity: CGFloat = 0.3
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
                let bounceSpeed = max(speed * 0.8, 1.5) // Збільшуємо мінімальну швидкість
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
    }
    
    private func startCelebration() {
        celebrationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.showCelebration = false
        }
    }
    
    func resetStats() {
        totalGames = 0
        bestScore = 0
        score = 0
    }
    
    func getPins() -> [Pin] { pins }
    func getSlots() -> [Slot] { slots }
}
