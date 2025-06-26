import SwiftUI

struct WeightSlider: View {
    @Binding var weight: Double
    let range: ClosedRange<Double> = 0...500
    let step: Double = 2.5

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(weight)) lb")
                .font(.subheadline)
            Slider(
                value: Binding(
                    get: { weight },
                    set: { newValue in
                        let snapped = (newValue / step).rounded() * step
                        weight = min(max(snapped, range.lowerBound), range.upperBound)
                    }
                ),
                in: range
            )
        }
        .padding(.vertical, 4)
    }
}
