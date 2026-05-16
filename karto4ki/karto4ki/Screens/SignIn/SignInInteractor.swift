import Foundation

private enum SignInFlowError: LocalizedError {
    case missingGoogleIdToken
    case missingAppleIdentityToken

    var errorDescription: String? {
        switch self {
        case .missingGoogleIdToken:
            return "Google не вернул id_token. Проверьте GOOGLE_CLIENT_ID и URL scheme."
        case .missingAppleIdentityToken:
            return "Apple не вернул identity token. Повторите вход."
        }
    }
}

final class SignInInteractor: SignInBusinessLogic {

    private let presenter: SignInPresentationLogic
    private let worker: SignInWorkerLogic
    private let errorHandler: ErrorHandlerProtocol

    init(presenter: SignInPresentationLogic, worker: SignInWorkerLogic, errorHandler: ErrorHandlerProtocol) {
        self.presenter = presenter
        self.worker = worker
        self.errorHandler = errorHandler
    }

    func getCode(_ email: String) {
        Task {
            do {
                let response = try await worker.sendCode(email: email)
                await MainActor.run {
                    if response.isExisted {
                        AppCoordinator.shared.showVerifyCodeScreen(flow: .signIn(signinKey: response.signinKey))
                    } else {
                        AppCoordinator.shared.showVerifyCodeScreen(flow: .signUp(signupKey: response.signinKey))
                    }
                }
            } catch {
                await errorHandler.handle(error)
            }
        }
    }

    func signInWithGoogle(idToken: String?, accessToken: String) {
        guard let idToken else {
            presenter.presentError()
            Task { await errorHandler.handle(SignInFlowError.missingGoogleIdToken) }
            return
        }
        Task {
            do {
                try await worker.signInWithGoogle(idToken: idToken)
                await MainActor.run {
                    AppCoordinator.shared.showMainScreen()
                }
            } catch {
                presenter.presentError()
                await errorHandler.handle(error)
            }
        }
    }

    func signInWithApple(userId: String, email: String?, fullName: PersonNameComponents?, identityToken: String?, authorizationCode: String?) {
        guard let identityToken else {
            presenter.presentError()
            Task { await errorHandler.handle(SignInFlowError.missingAppleIdentityToken) }
            return
        }
        Task {
            do {
                try await worker.signInWithApple(idToken: identityToken)
                await MainActor.run {
                    AppCoordinator.shared.showMainScreen()
                }
            } catch {
                presenter.presentError()
                await errorHandler.handle(error)
            }
        }
    }

    func appleSignInFailed(_ error: Error) {
        presenter.presentError()
        Task { await errorHandler.handle(error) }
    }

    func googleSignInFailed(_ error: Error) {
        presenter.presentError()
        Task { await errorHandler.handle(error) }
    }
}
