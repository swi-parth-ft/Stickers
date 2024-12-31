//
//  LiveTextImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-31.
//


import SwiftUI
import VisionKit

struct LiveTextImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit // Preserve aspect ratio and fit the image
        imageView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        imageView.isUserInteractionEnabled = true
        container.addSubview(imageView)

        // Add Auto Layout constraints to fit the image view to the container
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        // Add Live Text interaction if supported
        if isLiveTextSupported {
            let interaction = ImageAnalysisInteraction()
            interaction.preferredInteractionTypes = [.textSelection, .dataDetectors]
            imageView.addInteraction(interaction)

            Task {
                let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
                let analyzer = ImageAnalyzer()
                if let analysis = try? await analyzer.analyze(image, configuration: configuration) {
                    interaction.analysis = analysis
                }
            }
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed for now
    }
}
