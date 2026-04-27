protocol CodePresentationLogic {}

protocol CodeBusinessLogic {
    func sendVerificationRequest(code: String)
}

protocol CodeWorkerLogic {
    func verifyForSignIn(signinKey: String, code: String) async throws
    func verifyForSignUp(signupKey: String, code: String) async throws
}
