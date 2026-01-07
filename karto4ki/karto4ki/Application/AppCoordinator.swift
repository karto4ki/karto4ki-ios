//
//  AppCoordinator.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.12.2025.
//

import UIKit

final class AppCoordinator {
    
    static let shared = AppCoordinator()
    private let navigationController: UINavigationController
    private var window = UIWindow()
    private let userDefaults = UserDefaultsService()
    
    private init() {
        self.navigationController = UINavigationController()
    }
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if userDefaults.isOnboardingCompleted() {
            showRegistration()
        } else {
            showOnboarding()
        }
    }
    
    func showOnboarding() {
        let vc = OnboardingAssembly.build()
        navigationController.setViewControllers([vc], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showRegistration() {
        let signInVC = SignInAssembly.build()
        navigationController.setViewControllers([signInVC], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showVerifyCodeScreen() {
        let codeVC = CodeAssembly.build()
        navigationController.pushViewController(codeVC, animated: true)
    }
}
