import Foundation

final class CodeInteractor: CodeBusinessLogic {

    private let presenter: CodePresentationLogic
    private let worker: CodeWorkerLogic
    private let errorHandler: ErrorHandlerProtocol
    private let flow: AuthFlow

    init(presenter: CodePresentationLogic, worker: CodeWorkerLogic, errorHandler: ErrorHandlerProtocol, flow: AuthFlow) {
        self.presenter = presenter
        self.worker = worker
        self.errorHandler = errorHandler
        self.flow = flow
    }

    func sendVerificationRequest(code: String) {
        Task {
            do {
                switch flow {
                case .signIn(let signinKey):
                    try await worker.verifyForSignIn(signinKey: signinKey, code: code)
                    await MainActor.run {
                        AppCoordinator.shared.showMainScreen()
                    }

                case .signUp(let signupKey):
                    try await worker.verifyForSignUp(signupKey: signupKey, code: code)
                    await MainActor.run {
                        AppCoordinator.shared.showRegistration()
                    }
                }
            } catch {
                await errorHandler.handle(error)
            }
        }
    }
}
