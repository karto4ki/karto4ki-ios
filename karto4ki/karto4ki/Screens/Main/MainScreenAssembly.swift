import Foundation

struct MainScreenAssembly {
    static func build() -> MainScreenViewController {
        let presenter = MainScreenPresenter()
        let interactor = MainScreenInteractor(presenter: presenter)
        let view = MainScreenViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
