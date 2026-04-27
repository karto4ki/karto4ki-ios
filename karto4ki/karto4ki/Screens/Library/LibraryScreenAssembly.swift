import Foundation

struct LibraryScreenAssembly {
    static func build() -> LibraryScreenViewController {
        let presenter = LibraryScreenPresenter()
        let interactor = LibraryScreenInteractor(presenter: presenter)
        let view = LibraryScreenViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
