//
//  BackgroundView.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.12.2025.
//

import UIKit

final class BackgroundView: UIView {
    
    init(with name: String) {
        super.init(frame: .zero)
        configure(name)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure("background")
    }
    
    private func configure(_ name: String) {
        let background = UIImage(named: name)
        let backgroundView = UIImageView(image: background)
        backgroundView.contentMode = .scaleToFill
        addSubview(backgroundView)
        backgroundView.pinTop(to: topAnchor)
        backgroundView.pinLeft(to: leadingAnchor)
        backgroundView.pinBottom(to: bottomAnchor)
        backgroundView.pinRight(to: trailingAnchor)

        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 0.1
        backgroundView.addSubview(blurView)
        blurView.pinTop(to: backgroundView.topAnchor)
        blurView.pinLeft(to: backgroundView.leadingAnchor)
        blurView.pinBottom(to: backgroundView.bottomAnchor)
        blurView.pinRight(to: backgroundView.trailingAnchor)
    }
}

