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
    private let context: Context
    
    private init() {
        self.navigationController = UINavigationController()
        let keychainManager = KeychainManager()
        let identityService = MockIdentityService()
        context = .init(keychainManager: keychainManager,
                        userDefaults: UserDefaultsManager(),
                        identityService: identityService,
                        errorHandler: ErrorHandler(keychainManager: keychainManager, identityService: identityService))
        
    }
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if context.userDefaults.isOnboardingCompleted() {
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
        let signInVC = SignInAssembly.build(context: context)
        navigationController.setViewControllers([signInVC], animated: true)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showVerifyCodeScreen() {
        let codeVC = CodeAssembly.build(context: context)
        navigationController.pushViewController(codeVC, animated: true)
    }
    
    func showRegistration() {
        let regVC = RegistrationAssembly.build(context: context)
        navigationController.pushViewController(regVC, animated: true)
    }
    
    func showRegistrationConfirmation(name: String, username: String, goBackClosure: @escaping (Bool) -> Void?, routingClosure: @escaping (String, String) -> Void?) {
        let confirmVC = RegistrationConfirmViewController(name: name, username: username, goBackClosure: goBackClosure, routingClosure: routingClosure)
        navigationController.pushViewController(confirmVC, animated: true)
    }
}
