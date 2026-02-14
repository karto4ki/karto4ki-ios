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
    private let userDefaults = UserDefaultsManager()
    private let keychainManager = KeychainManager()
    private let identityService = MockIdentityService()
    
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
        let signInVC = SignInAssembly.build(keychain: keychainManager, identity: identityService)
        navigationController.setViewControllers([signInVC], animated: true)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showVerifyCodeScreen() {
        let codeVC = CodeAssembly.build(keychain: keychainManager, identity: identityService)
        navigationController.pushViewController(codeVC, animated: true)
    }
    
    func showRegistration() {
        let regVC = RegistrationAssembly.build(identity: identityService, keychain: keychainManager, userDefaults: userDefaults)
        navigationController.pushViewController(regVC, animated: true)
    }
    
    func showRegistrationConfirmation(name: String, username: String, goBackClosure: @escaping (Bool) -> Void?, routingClosure: @escaping (String, String) -> Void?) {
        let confirmVC = RegistrationConfirmViewController(name: name, username: username, goBackClosure: goBackClosure, routingClosure: routingClosure)
        navigationController.pushViewController(confirmVC, animated: true)
    }
}
