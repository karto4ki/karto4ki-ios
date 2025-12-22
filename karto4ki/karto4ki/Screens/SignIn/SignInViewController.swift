//
//  SignInViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit

class SignInViewController: UIViewController {

    private let translucentBackgroundView: UIView = UIView()
    private let appleIDButton: UIButton = UIButton(type: .system)
    private let gmailButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        translucentBackgroundView.roundCorners([.topLeft, .topRight], radius: 60)
    }
    
    private func configureUI() {
        configureBackground()
        configureTranslucentBackground()
        configureAppleIdButton()
        configureGmailButton()
    }

    private func configureBackground() {
        let background = BackgroundView()
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }
    
    private func configureTranslucentBackground() {
        translucentBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.addSubview(translucentBackgroundView)
        translucentBackgroundView.pinBottom(to: view.bottomAnchor)
        translucentBackgroundView.pinLeft(to: view.leadingAnchor)
        translucentBackgroundView.pinRight(to: view.trailingAnchor)
        translucentBackgroundView.pinTop(to: view.centerYAnchor)
    }
    
    private func configureAppleIdButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Apple ID", attributes: container)
        appleIDButton.configuration = config
        view.addSubview(appleIDButton)
        appleIDButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 5)
        appleIDButton.pinLeft(to: view.leadingAnchor, 40)
        appleIDButton.pinRight(to: view.trailingAnchor, 40)
        appleIDButton.setHeight(50)
    }
    
    private func configureGmailButton() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "google")
        config.imagePlacement = .trailing
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemBlue
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Google", attributes: container)
        gmailButton.configuration = config
        gmailButton.layer.borderWidth = 1
        gmailButton.layer.borderColor = UIColor.systemBlue.cgColor
        gmailButton.layer.cornerRadius = 25
        view.addSubview(gmailButton)
        gmailButton.pinBottom(to: appleIDButton.topAnchor, 15)
        gmailButton.pinLeft(to: view.leadingAnchor, 40)
        gmailButton.pinRight(to: view.trailingAnchor, 40)
        gmailButton.setHeight(50)
    }
}

