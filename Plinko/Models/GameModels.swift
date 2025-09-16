//
//  GameModels.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import SwiftUI

// MARK: - Game Models
struct Ball {
    var position: CGPoint
    var velocity: CGVector
    let radius: CGFloat
    let color: Color = .blue
    
    init(position: CGPoint, velocity: CGVector, radius: CGFloat? = nil) {
        self.position = position
        self.velocity = velocity
        // Якщо radius не задано, розраховуємо на основі ширини екрану (оригінальний підхід)
        if let radius = radius {
            self.radius = radius
        } else {
            let screenWidth = UIScreen.main.bounds.width
            self.radius = screenWidth * 0.015 // 1.5% від ширини екрану
        }
    }
}

struct Pin {
    let position: CGPoint
    let radius: CGFloat
    let color: Color = .gray
    
    init(position: CGPoint, radius: CGFloat? = nil) {
        self.position = position
        // Якщо radius не задано, розраховуємо на основі ширини екрану (оригінальний підхід)
        if let radius = radius {
            self.radius = radius
        } else {
            let screenWidth = UIScreen.main.bounds.width
            self.radius = screenWidth * 0.01 // 1% від ширини екрану
        }
    }
}

struct Slot {
    let rect: CGRect
    let points: Int
    let color: Color
}
