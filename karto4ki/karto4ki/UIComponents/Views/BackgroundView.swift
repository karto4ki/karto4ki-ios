//
//  BackgroundView.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.12.2025.
//

import UIKit

final class BackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        gradientLayer.colors = [
            UIColor(red: 0.75, green: 0.77, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.75, green: 0.82, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.75, green: 0.72, blue: 1.00, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.55, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

