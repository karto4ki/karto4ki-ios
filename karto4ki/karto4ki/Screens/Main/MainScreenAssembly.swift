import Foundation

struct MainScreenAssembly {
    static func build(cardService: CardServiceProtocol) -> MainScreenViewController {
        let presenter = MainScreenPresenter()
        let interactor = MainScreenInteractor(presenter: presenter, cardService: cardService)
        let view = MainScreenViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
