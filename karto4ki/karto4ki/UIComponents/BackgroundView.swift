//
//  BackgroundView.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.12.2025.
//

import UIKit

final class BackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        let background = UIImage(named: "background")
        let backgroundView = UIImageView(image: background)
        backgroundView.contentMode = .scaleToFill
        addSubview(backgroundView)
        backgroundView.pinTop(to: topAnchor)
        backgroundView.pinLeft(to: leadingAnchor)
        backgroundView.pinBottom(to: bottomAnchor)
        backgroundView.pinRight(to: trailingAnchor)

        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        backgroundView.addSubview(blurView)
        blurView.pinTop(to: backgroundView.topAnchor)
        blurView.pinLeft(to: backgroundView.leadingAnchor)
        blurView.pinBottom(to: backgroundView.bottomAnchor)
        blurView.pinRight(to: backgroundView.trailingAnchor)
    }
}

