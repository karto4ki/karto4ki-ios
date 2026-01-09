//
//  EnterHeartLabel.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 09.01.2026.
//

import UIKit

final class EnterHeartLabel: UIView {
    
    private let word: String
    private let heart = UILabel()
    private let enterLabel = UILabel()
    let wordLabel = UILabel()
    
    init(with word: String) {
        self.word = word
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        configureHeart()
        configureEnterLabel()
        configureWordLabel()
    }
    
    private func configureHeart() {
        heart.text = "."
        heart.font = UIFont(name: "Musinka-Regular", size: 500)
        heart.textColor = .white
        heart.textAlignment = .center
        addSubview(heart)
        heart.pinTop(to: self.topAnchor)
        heart.pinCenterX(to: self.centerXAnchor)
    }
    
    private func configureEnterLabel() {
        enterLabel.text = "введите"
        enterLabel.font = UIFont(name: "UraBumBumSPRegular", size: 70)
        enterLabel.textColor = .white
        enterLabel.textAlignment = .center
        addSubview(enterLabel)
        enterLabel.pinTop(to: heart.bottomAnchor, -80)
        enterLabel.pinCenterX(to: self.centerXAnchor)
    }
    
    private func configureWordLabel() {
        wordLabel.text = word
        wordLabel.font = UIFont(name: "UraBumBumSPRegular", size: 150)
        wordLabel.textColor = .white
        wordLabel.textAlignment = .center
        addSubview(wordLabel)
        wordLabel.pinTop(to: enterLabel.bottomAnchor, -70)
        wordLabel.pinCenterX(to: self.centerXAnchor)
        wordLabel.pinBottom(to: bottomAnchor, 0)
    }
}
