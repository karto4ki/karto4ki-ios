import Foundation

protocol LibraryScreenBusinessLogic: AnyObject {
    func loadLibrary()
    func reloadLibrary()
    func deleteDeck(id: UUID)
}

protocol LibraryScreenPresentationLogic: AnyObject {
    func presentDecks(_ decks: [LibraryModels.DeckSet])
    func presentLoading(_ loading: Bool)
    func presentError(_ message: String)
}

protocol LibraryScreenDisplayLogic: AnyObject {
    func displayDecks(_ viewModel: LibraryModels.ViewModel)
    func displayLoading(_ isLoading: Bool)
    func displayError(_ message: String)
}
