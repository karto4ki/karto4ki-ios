import Foundation

struct LibraryScreenAssembly {
    static func build(cardService: CardServiceProtocol) -> LibraryScreenViewController {
        let presenter = LibraryScreenPresenter()
        let interactor = LibraryScreenInteractor(presenter: presenter, cardService: cardService)
        let view = LibraryScreenViewController(interactor: interactor, cardService: cardService)
        presenter.view = view
        return view
    }
}
