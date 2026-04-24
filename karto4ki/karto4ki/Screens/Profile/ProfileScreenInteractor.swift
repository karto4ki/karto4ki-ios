import Foundation

final class ProfileScreenInteractor: ProfileScreenBusinessLogic {

    private let presenter: ProfileScreenPresentationLogic

    init(presenter: ProfileScreenPresentationLogic) {
        self.presenter = presenter
    }

    func signOut() {
        AppCoordinator.shared.signOut()
    }
}
