import SwiftUI

public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let message: String
    public let buttonTitle: String?
    public let action: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.purple.opacity(0.12))
                    .frame(width: 88, height: 88)
                
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(Theme.purpleGradient)
            }
            .purpleGlow(radius: 12, opacity: 0.25)
            
            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let buttonTitle = buttonTitle, let action = action {
                GradientButton(title: buttonTitle, action: action)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
