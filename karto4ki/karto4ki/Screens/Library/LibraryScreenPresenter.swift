import Foundation

final class LibraryScreenPresenter: LibraryScreenPresentationLogic {

    weak var view: LibraryScreenDisplayLogic?

    func presentDecks(_ decks: [LibraryModels.DeckSet]) {
        let sorted = decks.sorted { $0.addedAt > $1.addedAt }
        let vm = LibraryModels.ViewModel(decks: sorted, isEmpty: sorted.isEmpty)
        Task { @MainActor in
            view?.displayLoading(false)
            view?.displayDecks(vm)
        }
    }

    func presentLoading(_ loading: Bool) {
        Task { @MainActor in
            view?.displayLoading(loading)
        }
    }

    func presentError(_ message: String) {
        Task { @MainActor in
            view?.displayLoading(false)
            view?.displayError(message)
        }
    }
}
