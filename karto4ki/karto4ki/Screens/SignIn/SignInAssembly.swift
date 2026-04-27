import Foundation

struct SignInAssembly {
    static func build(context: ContextProtocol) -> SignInViewController {
        let presenter = SignInPresenter()
        let worker = SignInWorker(
            identityService: context.identityService,
            keychainManager: context.keychainManager,
            userDefaults: context.userDefaults
        )
        let interactor = SignInInteractor(presenter: presenter, worker: worker, errorHandler: context.errorHandler)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
