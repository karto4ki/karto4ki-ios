import Foundation

final class MainScreenPresenter: MainScreenPresentationLogic {

    weak var view: MainScreenDisplayLogic?

    func presentData(
        friends: [MainScreenModels.Friend],
        streakDays: [MainScreenModels.StreakDay],
        currentStreak: Int,
        deckCarousel: [MainScreenModels.DeckCarouselItem]
    ) {
        let viewModel = MainScreenModels.ViewModel(
            friends: friends,
            streakDays: streakDays,
            currentStreakDayCount: currentStreak,
            deckCarousel: deckCarousel
        )
        view?.displayData(viewModel)
    }
}
