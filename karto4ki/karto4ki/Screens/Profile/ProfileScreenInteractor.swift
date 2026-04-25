import Foundation

final class ProfileScreenInteractor: ProfileScreenBusinessLogic {

    private let presenter: ProfileScreenPresentationLogic
    private let userService: UserServiceProtocol
    private let errorHandler: ErrorHandlerProtocol

    private var latestProfile: PrivateUserProfile?

    init(
        presenter: ProfileScreenPresentationLogic,
        userService: UserServiceProtocol,
        errorHandler: ErrorHandlerProtocol
    ) {
        self.presenter = presenter
        self.userService = userService
        self.errorHandler = errorHandler
    }

    func loadProfile() {
        presenter.presentLoading(true)
        Task {
            do {
                let profile = try await userService.getMe()
                await MainActor.run {
                    latestProfile = profile
                }
                presenter.presentProfile(profile)
            } catch {
                presenter.presentLoading(false)
                await errorHandler.handle(error)
            }
        }
    }

    func signOut() {
        AppCoordinator.shared.signOut()
    }

    func updateDisplayNameAndUsername(name: String, username: String) {
        guard let latest = latestProfile else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedUser.isEmpty else { return }

        presenter.presentLoading(true)
        Task {
            do {
                let updated = try await userService.updateMe(
                    UpdateProfileRequest(
                        name: trimmedName,
                        username: trimmedUser,
                        notificationEnabled: latest.notificationEnabled
                    )
                )
                await MainActor.run {
                    latestProfile = updated
                }
                presenter.presentProfile(updated)
            } catch {
                presenter.presentLoading(false)
                await errorHandler.handle(error)
            }
        }
    }

    func setNotificationEnabled(_ enabled: Bool) {
        guard let latest = latestProfile else { return }
        Task {
            do {
                let updated = try await userService.updateMe(
                    UpdateProfileRequest(
                        name: latest.name,
                        username: latest.username,
                        notificationEnabled: enabled
                    )
                )
                await MainActor.run {
                    latestProfile = updated
                }
                presenter.presentProfile(updated)
            } catch {
                await MainActor.run {
                    presenter.presentProfile(latest)
                }
                await errorHandler.handle(error)
            }
        }
    }

    func deleteAccount() {
        presenter.presentLoading(true)
        Task {
            do {
                try await userService.deleteMe()
                await MainActor.run {
                    presenter.presentLoading(false)
                    AppCoordinator.shared.signOut()
                }
            } catch {
                await MainActor.run {
                    presenter.presentLoading(false)
                }
                await errorHandler.handle(error)
            }
        }
    }
}
