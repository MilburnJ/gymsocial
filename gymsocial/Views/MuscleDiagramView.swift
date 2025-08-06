import SwiftUI
import UIKit    // ← for UIImage(named:)

/// A front/back body diagram with per‑muscle highlights.
struct MuscleDiagramView: View {
    let highlight: Set<MuscleGroup>

    var body: some View {
        HStack(spacing: 24) {
            diagram(side: "front")
            diagram(side: "back")
        }
        .padding()
    }

    @ViewBuilder
    private func diagram(side: String) -> some View {
        ZStack {
            Image("body_\(side)")
                .resizable()
                .scaledToFit()

            ForEach(MuscleGroup.allCases) { group in
                // Only attempt an overlay if it’s highlighted
                if highlight.contains(group) {
                    // Build the asset name
                    let assetName = "overlay_\(group.rawValue)_\(side)"

                    // Ask UIKit if that image actually exists
                    if let uiImage = UIImage(named: assetName) {
                        // If it does, show it
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.6)
                    }
                    // Otherwise do nothing (no crash, no console error)
                }
            }
        }
    }
}
