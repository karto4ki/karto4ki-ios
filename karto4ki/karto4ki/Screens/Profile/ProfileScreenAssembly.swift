import Foundation

struct ProfileScreenAssembly {
    static func build() -> ProfileScreenViewController {
        let presenter = ProfileScreenPresenter()
        let interactor = ProfileScreenInteractor(presenter: presenter)
        let view = ProfileScreenViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
