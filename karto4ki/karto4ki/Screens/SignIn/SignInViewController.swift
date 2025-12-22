//
//  SignInViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit

class SignInViewController: UIViewController {

    private let translucentBackgroundView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        translucentBackgroundView.roundCorners([.topLeft, .topRight], radius: 100)
    }
    
    private func configureUI() {
        configureBackground()
        configureTranslucentBackground()
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
}

