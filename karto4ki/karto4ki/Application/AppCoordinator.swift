import UIKit

final class AppCoordinator {

    static let shared = AppCoordinator()
    private let navigationController: UINavigationController
    private var window = UIWindow()
    private let context: Context

    private init() {
        self.navigationController = UINavigationController()
        let keychainManager = KeychainManager()
        let identityService = IdentityService()
        let userService = UserService()
        context = Context(
            keychainManager: keychainManager,
            userDefaults: UserDefaultsManager(),
            identityService: identityService,
            userService: userService,
            errorHandler: ErrorHandler(keychainManager: keychainManager)
        )
    }

    func setWindow(_ window: UIWindow) {
        self.window = window
    }

    func start() {
        guard context.userDefaults.isOnboardingCompleted() else {
            showOnboarding()
            return
        }

        let hasRefreshToken = context.keychainManager.getString(
            key: KeychainManager.Keys.refreshToken.rawValue
        ) != nil

        if hasRefreshToken {
            showMainScreen()
        } else {
            showSignIn()
        }
    }

    // MARK: - Navigation

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

    func showVerifyCodeScreen(flow: AuthFlow) {
        let codeVC = CodeAssembly.build(context: context, flow: flow)
        navigationController.pushViewController(codeVC, animated: true)
    }

    func showRegistration() {
        let regVC = RegistrationAssembly.build(context: context)
        navigationController.pushViewController(regVC, animated: true)
    }

    func showRegistrationConfirmation(name: String, username: String,
                                      goBackClosure: @escaping (Bool) -> Void?,
                                      routingClosure: @escaping (String, String) -> Void?) {
        let confirmVC = RegistrationConfirmViewController(
            name: name, username: username,
            goBackClosure: goBackClosure, routingClosure: routingClosure
        )
        navigationController.pushViewController(confirmVC, animated: true)
    }

    func showMainScreen() {
        let tabVC = TabContainerViewController()
        navigationController.setViewControllers([tabVC], animated: true)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Sign Out

    func signOut() {
        Task {
            if let refreshToken = context.keychainManager.getString(
                key: KeychainManager.Keys.refreshToken.rawValue
            ) {
                try? await context.identityService.signOut(refreshToken: refreshToken)
            }
            _ = context.keychainManager.deleteTokens()
            await MainActor.run {
                showSignIn()
            }
        }
    }
}
