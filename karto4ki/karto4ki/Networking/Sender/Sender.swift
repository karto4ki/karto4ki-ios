import Foundation

final class Sender {

    static let shared = Sender()

    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let keychainManager = KeychainManager()
    private let retryDelays: [UInt64] = [1_000_000_000, 3_000_000_000, 10_000_000_000]

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
            apiRoot: ServerBaseURL.primaryAPIRoot,
            endpoint: endpoint, method: method,
            headers: headers, payload: .json(body),
            authenticated: authenticated
        )
        print("🔍 \(String(decoding: data, as: UTF8.self))")
        return try decoder.decode(SuccessResponse<T>.self, from: data).data
    }

    /// `multipart/form-data` (например загрузка файлов в storage).
    func requestMultipart<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        multipartBody: Data,
        boundary: String,
        authenticated: Bool = false
    ) async throws -> T {
        let data = try await perform(
            apiRoot: ServerBaseURL.fileStorageAPIRoot,
            endpoint: endpoint, method: method,
            headers: headers,
            payload: .multipart(multipartBody, boundary: boundary),
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
            apiRoot: ServerBaseURL.primaryAPIRoot,
            endpoint: endpoint, method: method,
            headers: headers, payload: .json(body),
            authenticated: authenticated
        )
    }

    // MARK: - Private

    private enum RequestPayload {
        case json(Data?)
        case multipart(Data, boundary: String)
    }

    private func perform(
        apiRoot: String,
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String],
        payload: RequestPayload,
        authenticated: Bool,
        attempt: Int = 0
    ) async throws -> Data {
        let root = apiRoot.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = endpoint.hasPrefix("/") ? endpoint : "/" + endpoint
        guard let url = URL(string: "\(root)\(path)") else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        switch payload {
        case .json(let body):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        case .multipart(let body, let boundary):
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            request.timeoutInterval = 120
        }

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if authenticated,
           let token = keychainManager.getString(key: KeychainManager.Keys.accessToken.rawValue) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

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
                    apiRoot: apiRoot,
                    endpoint: endpoint, method: method,
                    headers: headers, payload: payload,
                    authenticated: authenticated, attempt: attempt + 1
                )

            case 500...599:
                guard attempt < retryDelays.count else { throw decodeError(data) }
                try await Task.sleep(nanoseconds: retryDelays[attempt])
                return try await perform(
                    apiRoot: apiRoot,
                    endpoint: endpoint, method: method,
                    headers: headers, payload: payload,
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
                apiRoot: apiRoot,
                endpoint: endpoint, method: method,
                headers: headers, payload: payload,
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
