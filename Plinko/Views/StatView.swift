import SwiftUI

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
