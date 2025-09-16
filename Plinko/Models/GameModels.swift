
import SwiftUI

struct Ball {
    var position: CGPoint
    var velocity: CGVector
    let radius: CGFloat
    let color: Color = .blue
    
    init(position: CGPoint, velocity: CGVector, radius: CGFloat? = nil) {
        self.position = position
        self.velocity = velocity
        if let radius = radius {
            self.radius = radius
        } else {
            let screenWidth = UIScreen.main.bounds.width
            self.radius = screenWidth * 0.015
        }
    }
}

struct Pin {
    let position: CGPoint
    let radius: CGFloat
    let color: Color = .gray
    
    init(position: CGPoint, radius: CGFloat? = nil) {
        self.position = position
        if let radius = radius {
            self.radius = radius
        } else {
            let screenWidth = UIScreen.main.bounds.width
            self.radius = screenWidth * 0.01 
        }
    }
}

struct Slot {
    let rect: CGRect
    let points: Int
    let color: Color
}
