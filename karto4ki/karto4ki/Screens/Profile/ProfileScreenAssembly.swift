import Foundation

struct ProfileScreenAssembly {
    static func build(context: ContextProtocol) -> ProfileScreenViewController {
        let presenter = ProfileScreenPresenter()
        let interactor = ProfileScreenInteractor(
            presenter: presenter,
            userService: context.userService,
            fileStorageService: context.fileStorageService,
            errorHandler: context.errorHandler
        )
        let view = ProfileScreenViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
