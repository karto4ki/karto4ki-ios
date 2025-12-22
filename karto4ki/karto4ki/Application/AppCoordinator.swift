//
//  AppCoordinator.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 22.12.2025.
//

import UIKit

final class AppCoordinator {
    
    static let shared = AppCoordinator()
    private let navigatorController: UINavigationController
    private var window = UIWindow()
    
    private init() {
        self.navigatorController = UINavigationController()
    }
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    func startRegistration() {
        window.rootViewController = SignInViewController()
        window.makeKeyAndVisible()
    }
}
