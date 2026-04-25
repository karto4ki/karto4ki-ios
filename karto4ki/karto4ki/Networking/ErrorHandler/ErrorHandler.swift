import UIKit

final class ErrorHandler: ErrorHandlerProtocol {

    private let keychainManager: KeychainManagerProtocol
    private let userDefaults: UserDefaultsManagerProtocol

    init(keychainManager: KeychainManagerProtocol, userDefaults: UserDefaultsManagerProtocol) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
    }

    @MainActor
    func handle(_ error: Error) {
        guard let message = mapError(error) else { return }
        showAlert(message: message)
    }

    func handleSessionExpired() {
        keychainManager.clearSessionSecrets()
        userDefaults.clearSessionCaches()
        DispatchQueue.main.async {
            AppCoordinator.shared.showSignIn()
        }
    }

    // MARK: - Mapping

    private func mapError(_ error: Error) -> String? {
        if let apiError = error as? ApiErrorResponse {
            return mapApiResponse(apiError)
        }
        if let apiError = error as? ApiError {
            return mapApiError(apiError)
        }
        let message = (error as NSError).localizedDescription
        return message.isEmpty ? "Произошла ошибка" : message
    }

    private func mapApiResponse(_ error: ApiErrorResponse) -> String? {
        switch error.errorType {
        case ApiErrorTypes.refreshTokenExpired.rawValue,
             ApiErrorTypes.refreshTokenInvalidated.rawValue,
             ApiErrorTypes.unauthorized.rawValue,
             ApiErrorTypes.invalidToken.rawValue:
            handleSessionExpired()
            return nil

        case ApiErrorTypes.sendCodeFreqExceeded.rawValue:
            return "Код уже отправлен. Подождите перед повторной попыткой"

        case ApiErrorTypes.wrongCode.rawValue:
            return "Неверный код"

        case ApiErrorTypes.userAlreadyExists.rawValue:
            return "Такой пользователь уже существует"

        case ApiErrorTypes.validationFailed.rawValue:
            if let details = error.errorDetails, !details.isEmpty {
                return details.map { $0.message }.joined(separator: "\n")
            }
            return "Проверьте введённые данные"

        case ApiErrorTypes.signinKeyNotFound.rawValue:
            return "Сессия истекла. Запросите код повторно"

        case ApiErrorTypes.wrongToken.rawValue:
            return "Ошибка авторизации"

        default:
            return error.errorMessage
        }
    }

    private func mapApiError(_ error: ApiError) -> String {
        switch error {
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .invalidURL, .invalidResponse, .decodingError:
            return "Произошла ошибка. Попробуйте позже"
        case .noData:
            return "Нет данных от сервера"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }

    // MARK: - Alert

    @MainActor
    private func showAlert(message: String) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topVC.present(alert, animated: true)
    }
}
