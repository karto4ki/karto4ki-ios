import Foundation

final class Sender {

    static let shared = Sender()

    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let keychainManager = KeychainManager()
    private let retryDelays: [UInt64] = [1_000_000_000, 3_000_000_000, 10_000_000_000]

    private var baseURL: String {
        #if targetEnvironment(simulator)
        let preferredKey = "SERVER_BASE_URL_SIMULATOR"
        #else
        let preferredKey = "SERVER_BASE_URL_DEVICE"
        #endif

        if let preferred = Bundle.main.object(forInfoDictionaryKey: preferredKey) as? String,
           !preferred.isEmpty {
            return preferred
        }

        if let legacy = Bundle.main.object(forInfoDictionaryKey: "SERVER_BASE_URL") as? String,
           !legacy.isEmpty {
            return legacy
        }

        fatalError("SERVER_BASE_URL_* not configured in Info.plist")
    }

    private init() {}

    // MARK: - Public

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        authenticated: Bool = false
    ) async throws -> T {
        let data = try await perform(
            endpoint: endpoint, method: method,
            headers: headers, body: body,
            authenticated: authenticated
        )
        print("🔍 \(String(decoding: data, as: UTF8.self))")
        return try decoder.decode(SuccessResponse<T>.self, from: data).data
    }

    func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        authenticated: Bool = false
    ) async throws {
        _ = try await perform(
            endpoint: endpoint, method: method,
            headers: headers, body: body,
            authenticated: authenticated
        )
    }

    // MARK: - Private

    private func perform(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        body: Data?,
        authenticated: Bool,
        attempt: Int = 0
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if authenticated,
           let token = keychainManager.getString(key: KeychainManager.Keys.accessToken.rawValue) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw ApiError.invalidResponse
            }

            switch http.statusCode {
            case 200:
                return data

            case 401:
                guard authenticated,
                      endpoint != IdentityServiceEndpoints.refreshToken.rawValue
                else {
                    throw decodeError(data)
                }
                
                guard attempt == 0 else {
                    throw final401Error(data)
                }
                try await TokenManager.shared.refreshTokens()
                return try await perform(
                    endpoint: endpoint, method: method,
                    headers: headers, body: body,
                    authenticated: authenticated, attempt: attempt + 1
                )

            case 500...599:
                guard attempt < retryDelays.count else { throw decodeError(data) }
                try await Task.sleep(nanoseconds: retryDelays[attempt])
                return try await perform(
                    endpoint: endpoint, method: method,
                    headers: headers, body: body,
                    authenticated: authenticated, attempt: attempt + 1
                )

            default:
                throw decodeError(data)
            }

        } catch let err as ApiErrorResponse { throw err }
          catch let err as ApiError          { throw err }
          catch {
            guard attempt < retryDelays.count else { throw ApiError.networkError(error) }
            try await Task.sleep(nanoseconds: retryDelays[attempt])
            return try await perform(
                endpoint: endpoint, method: method,
                headers: headers, body: body,
                authenticated: authenticated, attempt: attempt + 1
            )
        }
    }

    private func decodeError(_ data: Data) -> Error {
        do {
            return try decoder.decode(ApiErrorResponse.self, from: data)
        } catch {
            return ApiError.decodingError(error)
        }
    }

    /// После неудачного refresh тело 401 может быть пустым или не JSON — всё равно выкидываем в `unauthorized`.
    private func final401Error(_ data: Data) -> Error {
        if let decoded = try? decoder.decode(ApiErrorResponse.self, from: data) {
            return decoded
        }
        return ApiErrorResponse(
            errorType: ApiErrorTypes.unauthorized.rawValue,
            errorMessage: "Unauthorized",
            errorDetails: nil
        )
    }
}
