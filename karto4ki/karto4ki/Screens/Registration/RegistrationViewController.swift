//
//  RegistrationViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import UIKit

final class RegistrationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        configureBackground()
    }
    
    private func configureBackground() {
        let background = BackgroundView(with: "background-10")
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }
}
