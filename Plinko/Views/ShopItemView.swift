import SwiftUI

struct ShopItemView: View {
    let item: ShopItem
    let onPurchase: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(itemBackgroundColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(itemBorderColor, lineWidth: 2)
                    )
                
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundColor(itemIconColor)
            }
            
            VStack(spacing: 4) {
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(PlinkoTheme.Palette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.caption2)
                    .foregroundColor(PlinkoTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(PlinkoTheme.Palette.gold)
                        .font(.caption2)
                    Text("\(item.price)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(PlinkoTheme.Palette.gold)
                }
            }
            
            Button(action: onPurchase) {
                Text(buttonText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(buttonTextColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(buttonBackgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(buttonBorderColor, lineWidth: 1)
                    )
            }
            .disabled(!canPurchase)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PlinkoTheme.Palette.backgroundDark.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(itemBorderColor.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: PlinkoTheme.Shadow.sphereShadow, radius: 5)
        .onTapGesture {
            onTap()
        }
    }
    
    private var canPurchase: Bool {
        !item.isPurchased && item.isAvailable
    }
    
    private var buttonText: String {
        if item.isPurchased {
            return "Owned"
        } else if !item.isAvailable {
            return "Locked"
        } else {
            return "Buy"
        }
    }
    
    private var itemBackgroundColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold.opacity(0.3)
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.darkGray
        } else {
            return item.color.opacity(0.2)
        }
    }
    
    private var itemBorderColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.textTertiary
        } else {
            return item.color
        }
    }
    
    private var itemIconColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.textTertiary
        } else {
            return item.color
        }
    }
    
    private var buttonTextColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.textTertiary
        } else {
            return PlinkoTheme.Palette.textPrimary
        }
    }
    
    private var buttonBackgroundColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold.opacity(0.2)
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.darkGray
        } else {
            return item.color.opacity(0.3)
        }
    }
    
    private var buttonBorderColor: Color {
        if item.isPurchased {
            return PlinkoTheme.Palette.gold
        } else if !item.isAvailable {
            return PlinkoTheme.Palette.textTertiary
        } else {
            return item.color
        }
    }
}
