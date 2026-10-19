import SwiftUI

public struct WaveformVisualizerView: View {
    public let isPlaying: Bool
    public let barCount: Int
    
    @State private var phase: CGFloat = 0
    
    public init(isPlaying: Bool, barCount: Int = 24) {
        self.isPlaying = isPlaying
        self.barCount = barCount
    }
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<barCount, id: \.self) { index in
                    let height = computeBarHeight(index: index, time: date)
                    Capsule()
                        .fill(Theme.waveformGradient)
                        .frame(width: 3, height: height)
                }
            }
            .frame(height: 36)
        }
    }
    
    private func computeBarHeight(index: Int, time: Double) -> CGFloat {
        guard isPlaying else { return 4 }
        let frequency = Double(index + 1) * 0.45
        let wave = sin(time * 6.0 + frequency) * 0.5 + 0.5
        let harmonic = cos(time * 3.5 + Double(index) * 0.3) * 0.3
        let rawHeight = (wave + harmonic) * 32.0 + 4.0
        return max(4.0, min(36.0, CGFloat(rawHeight)))
    }
}
