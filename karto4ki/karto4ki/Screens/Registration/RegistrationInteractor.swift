import Foundation

final class RegistrationInteractor: RegistrationBusinessLogic {

    private let worker: RegistrationWorkerLogic
    private let errorHandler: ErrorHandlerProtocol

    init(worker: RegistrationWorkerLogic, errorHandler: ErrorHandlerProtocol) {
        self.worker = worker
        self.errorHandler = errorHandler
    }

    func goToConfirmation(name: String, username: String,
                          goBackClosure: @escaping (Bool) -> Void?,
                          routingClosure: @escaping (String, String) -> Void?) {
        AppCoordinator.shared.showRegistrationConfirmation(
            name: name, username: username,
            goBackClosure: goBackClosure, routingClosure: routingClosure
        )
    }

    func confirm(name: String, username: String) {
        Task {
            do {
                try await worker.signUp(name: name, username: username)
                await MainActor.run {
                    AppCoordinator.shared.showMainScreen()
                }
            } catch {
                await errorHandler.handle(error)
            }
        }
    }
}
