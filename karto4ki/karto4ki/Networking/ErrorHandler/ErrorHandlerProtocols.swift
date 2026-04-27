import Foundation

protocol ErrorHandlerProtocol {
    @MainActor func handle(_ error: Error)
    func handleSessionExpired()
}
