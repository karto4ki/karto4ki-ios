import Foundation

final class MainScreenPresenter: MainScreenPresentationLogic {

    weak var view: MainScreenDisplayLogic?

    func presentData(
        friends: [MainScreenModels.Friend],
        streakDays: [MainScreenModels.StreakDay],
        recentDeck: MainScreenModels.DeckCard,
        progress: MainScreenModels.ProgressData
    ) {
        let viewModel = MainScreenModels.ViewModel(
            friends: friends,
            streakDays: streakDays,
            recentDeck: recentDeck,
            progress: progress
        )
        view?.displayData(viewModel)
    }
}
