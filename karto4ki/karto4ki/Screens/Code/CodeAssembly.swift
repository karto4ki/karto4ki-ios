import Foundation

struct CodeAssembly {
    static func build(context: ContextProtocol, flow: AuthFlow) -> CodeViewController {
        let presenter = CodePresenter()
        let worker = CodeWorker(identityService: context.identityService, keychainManager: context.keychainManager)
        let interactor = CodeInteractor(presenter: presenter, worker: worker, errorHandler: context.errorHandler, flow: flow)
        let view = CodeViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
