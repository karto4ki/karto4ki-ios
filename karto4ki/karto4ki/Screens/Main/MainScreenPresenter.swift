import Foundation

final class MainScreenPresenter: MainScreenPresentationLogic {

    weak var view: MainScreenDisplayLogic?

    func presentData(
        friends: [MainScreenModels.Friend],
        streakDays: [MainScreenModels.StreakDay],
        deckCarousel: [MainScreenModels.DeckCarouselItem]
    ) {
        let streakCount = MainScreenModels.currentStreakLength(days: streakDays)
        let viewModel = MainScreenModels.ViewModel(
            friends: friends,
            streakDays: streakDays,
            currentStreakDayCount: streakCount,
            deckCarousel: deckCarousel
        )
        view?.displayData(viewModel)
    }
}
