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
    let radius: CGFloat = 8
    let color: Color = .blue
}

struct Pin {
    let position: CGPoint
    let radius: CGFloat = 6
    let color: Color = .gray
}

struct Slot {
    let rect: CGRect
    let points: Int
    let color: Color
}
