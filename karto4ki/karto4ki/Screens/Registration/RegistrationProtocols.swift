import Foundation

protocol RegistrationBusinessLogic {
    func confirm(name: String, username: String)
    func goToConfirmation(name: String,
                          username: String,
                          goBackClosure: @escaping (Bool) -> Void?,
                          routingClosure: @escaping (String, String) -> Void?)
}

protocol RegistrationWorkerLogic {
    func signUp(name: String, username: String) async throws
}
