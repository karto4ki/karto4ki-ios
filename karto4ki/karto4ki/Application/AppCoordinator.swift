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
            showSignIn()
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
    
    func showSignIn() {
        let signInVC = SignInAssembly.build()
        navigationController.setViewControllers([signInVC], animated: true)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showVerifyCodeScreen() {
        let codeVC = CodeAssembly.build()
        navigationController.pushViewController(codeVC, animated: true)
    }
    
    func showRegistration() {
        let regVC = RegistrationAssembly.build()
        navigationController.pushViewController(regVC, animated: true)
    }
    
    func showRegistrationConfirmation(name: String, username: String, closure: @escaping (Bool) -> Void) {
        let confirmVC = RegistrationConfitmViewController(name: name, username: username, closure: closure)
        navigationController.pushViewController(confirmVC, animated: true)
    }
}
