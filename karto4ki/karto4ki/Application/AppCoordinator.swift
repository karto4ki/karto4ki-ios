import UIKit

final class AppCoordinator {

    static let shared = AppCoordinator()
    private let navigationController: UINavigationController
    private var window = UIWindow()
    private let context: Context

    private init() {
        self.navigationController = UINavigationController()
        let keychainManager = KeychainManager()
        let userDefaults = UserDefaultsManager()
        let identityService = IdentityService()
        let userService = UserService(userDefaultsManager: userDefaults)
        let fileStorageService = FileStorageService()
        let cardService = CardService()
        context = Context(
            keychainManager: keychainManager,
            userDefaults: userDefaults,
            identityService: identityService,
            userService: userService,
            fileStorageService: fileStorageService,
            cardService: cardService,
            errorHandler: ErrorHandler(keychainManager: keychainManager, userDefaults: userDefaults)
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
        let tabVC = TabContainerViewController(context: context)
        navigationController.setViewControllers([tabVC], animated: true)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        // Фоновый prefetch сразу после входа: профиль + список наборов
        Task { await prefetchOnLogin() }
    }

    /// Загружает профиль и наборы карточек сразу после авторизации.
    /// Не блокирует UI — данные просто оседают в LocalDataStore и AppCacheStore,
    /// экраны при открытии найдут свежий кэш и не пойдут в сеть.
    private func prefetchOnLogin() async {
        async let _ = prefetchProfile()
        async let _ = prefetchSets()
    }

    private func prefetchProfile() async {
        do {
            let profile = try await context.userService.getMe()
            await LocalDataStore.shared.saveProfile(profile)
        } catch {
            // Профиль будет загружен при первом открытии экрана профиля
        }
    }

    private func prefetchSets() async {
        guard AppCacheStore.setsExpired else { return }
        do {
            _ = try await context.cardService.getSets(offset: nil, limit: nil)
            // getSets уже сохранил в LocalDataStore и обновил AppCacheStore
        } catch {
            // Библиотека будет загружена при открытии экрана
        }
    }

    // MARK: - Sign Out

    func signOut() {
        Task {
            if let refreshToken = context.keychainManager.getString(
                key: KeychainManager.Keys.refreshToken.rawValue
            ) {
                try? await context.identityService.signOut(refreshToken: refreshToken)
            }
            context.keychainManager.clearSessionSecrets()
            context.userDefaults.clearSessionCaches()
            // Сбрасываем все TTL-метки и SwiftData кэш
            AppCacheStore.invalidateAll()
            await LocalDataStore.shared.clearAll()
            await MainActor.run {
                showSignIn()
            }
        }
    }
}
