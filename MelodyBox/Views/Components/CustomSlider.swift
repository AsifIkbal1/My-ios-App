import SwiftUI

public struct CustomSlider: View {
    @Binding public var value: Double // 0.0 to 1.0
    public var onEditingChanged: ((Bool) -> Void)?
    
    @State private var isDragging: Bool = false
    @State private var dragProgress: Double = 0.0
    
    public init(value: Binding<Double>, onEditingChanged: ((Bool) -> Void)? = nil) {
        self._value = value
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let currentVal = isDragging ? dragProgress : value
            let clampedVal = max(0.0, min(1.0, currentVal))
            let width = geometry.size.width
            let progressWidth = width * CGFloat(clampedVal)
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: isDragging ? 6 : 4)
                
                // Active Progress Track
                Capsule()
                    .fill(Theme.purpleGradient)
                    .frame(width: progressWidth, height: isDragging ? 6 : 4)
                    .purpleGlow(radius: 6, opacity: 0.5)
                
                // Glowing Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: isDragging ? 18 : 12, height: isDragging ? 18 : 12)
                    .purpleGlow(radius: 8, opacity: 0.6)
                    .offset(x: max(0, min(width - (isDragging ? 18 : 12), progressWidth - (isDragging ? 9 : 6))))
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        let rawRatio = gesture.location.x / width
                        dragProgress = max(0.0, min(1.0, Double(rawRatio)))
                    }
                    .onEnded { _ in
                        value = dragProgress
                        isDragging = false
                        onEditingChanged?(false)
                    }
            )
            .animation(.easeOut(duration: 0.1), value: isDragging)
        }
        .frame(height: 24)
    }
}
