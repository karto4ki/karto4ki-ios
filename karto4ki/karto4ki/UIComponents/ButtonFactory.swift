//
//  ButtonFactory.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.02.2026.
//

import UIKit

final class ButtonFactory {
    
    static func makeButton(title: String, titleColor: UIColor, backgroundColor: UIColor, borderColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor
        config.background.cornerRadius = 25

        var container = AttributeContainer()
        container.font = UIFont(name: "futuralt-bold", size: 20)
        config.attributedTitle = AttributedString(title, attributes: container)
        button.configuration = config
        button.setHeight(50)
        button.layer.borderColor = borderColor.cgColor
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        
        return button
    }
}
