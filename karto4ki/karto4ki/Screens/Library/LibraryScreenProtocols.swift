import Foundation

protocol LibraryScreenBusinessLogic: AnyObject {
    func loadLibrary()
    func deleteDeck(id: UUID)
}

protocol LibraryScreenPresentationLogic: AnyObject {
    func presentDecks(_ decks: [LibraryModels.DeckSet])
    func presentLoading(_ loading: Bool)
}

protocol LibraryScreenDisplayLogic: AnyObject {
    func displayDecks(_ viewModel: LibraryModels.ViewModel)
    func displayLoading(_ isLoading: Bool)
}
