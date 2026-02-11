//
//  Sender.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

final class Sender {
    
    private static let baseURLKey = "SERVER_BASE_URL"
    private static let delays: [TimeInterval] = [1,3,10]
    
    static func send<T: Codable>(endpoint: String,
                                 method: HTTPMethod,
                                 headers: [String:String]? = nil,
                                 body: Data? = nil,
                                 attempt: Int = 0,
                                 completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: baseURLKey) else {
            fatalError("Can't get baseURL")
        }
        
        // TODO: remove print
        print("\(baseURL)\(endpoint)")
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpBody = body
        
        sendRequest(request: request, attempt: attempt, endpoint: endpoint, method: method, headers: headers, body: body, completion: completion)
    }
    
    private static func sendRequest<T: Codable>(request: URLRequest,
                                                attempt: Int,
                                                endpoint: String,
                                                method: HTTPMethod,
                                                headers: [String: String]?,
                                                body: Data?,
                                                completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handleNetworkError(error, attempt: attempt, endpoint: endpoint, method: method, headers: headers, body: body, completion: completion)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ApiError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.noData))
                return
            }
            
            handleResponse(httpResponse, data: data, attempt: attempt, endpoint: endpoint, method: method, headers: headers, body: data, completion: completion)
        }
        
        task.resume()
    }
    
    private static func handleNetworkError<T: Codable>(_ error: Error,
                                                       attempt: Int,
                                                       endpoint: String,
                                                       method: HTTPMethod,
                                                       headers: [String: String]?,
                                                       body: Data?,
                                                       completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        if attempt < delays.count {
            let delay = delays[attempt]
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                send(endpoint: endpoint,
                     method: method,
                     headers: headers,
                     body: body,
                     attempt: attempt + 1,
                     completion: completion)
            }
        } else {
            completion(.failure(ApiError.networkError(error)))
        }
    }
    
    private static func handleResponse<T: Codable>(_ response: HTTPURLResponse,
                                                   data: Data,
                                                   attempt: Int,
                                                   endpoint: String,
                                                   method: HTTPMethod,
                                                   headers: [String: String]?,
                                                   body: Data?,
                                                   completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        let jsonString = String(data: data, encoding: .utf8)
        
        switch response.statusCode {
        case 200:
            decodeResponse(data, completion: completion)
        case 401:
            // TODO: check if the refresh bug was fixed
            if endpoint == IdentityServiceEndpoints.refreshToken.rawValue {
                decodeErrorResponse(data: data, completion: completion)
            } else {
                handleUnauthorizedError(attempt: attempt, endpoint: endpoint, method: method, headers: headers, body: body, completion: completion
                )
            }
        case 500...599:
            handleServerError(attempt: attempt, endpoint: endpoint, method: method, headers: headers, body: body, completion: completion, data: data)
        default:
            decodeErrorResponse(data: data, completion: completion)
        }
    }
    
    private static func decodeResponse<T: Codable>(_ data: Data,
                                                   completion: (Result<SuccessResponse<T>, Error>) -> Void) {
        do {
            let responseData = try JSONDecoder().decode(SuccessResponse<T>.self, from: data)
            completion(.success(responseData))
        } catch {
            completion(.failure(ApiError.decodingError(error)))
        }
    }
    
    private static func handleUnauthorizedError<T: Codable>(attempt: Int,
                                                            endpoint: String,
                                                            method: HTTPMethod,
                                                            headers: [String: String]?,
                                                            body: Data?,
                                                            completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        TokenManager.refreshAccessToken { result in
            switch result {
            case .success(let response):
                let tokens = response.data
                TokenManager.saveTokensToKeychain(tokens: tokens)
                
                send(endpoint: endpoint, method: method, headers: headers, body: body, attempt: attempt + 1, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func handleServerError<T: Codable>(attempt: Int,
                                                      endpoint: String,
                                                      method: HTTPMethod,
                                                      headers: [String: String]?,
                                                      body: Data?,
                                                      completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void,
                                                      data: Data) {
        if attempt < delays.count {
            let delay = delays[attempt]
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                send(endpoint: endpoint,
                     method: method,
                     headers: headers,
                     body: body,
                     attempt: attempt + 1,
                     completion: completion)
            }
        } else {
            decodeErrorResponse(data: data, completion: completion)
        }
    }
    
    private static func decodeErrorResponse<T: Codable>(data: Data,
                                                        completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void) {
        do {
            let errorResponse = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
            completion(.failure(errorResponse))
        } catch {
            completion(.failure(ApiError.decodingError(error)))
        }
    }
}
