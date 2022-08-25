import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol HTTPClient {
    func fetch(request: URLRequest) async throws -> String
}

struct HTTPClientImpl: HTTPClient {
    let urlSession: URLSession

    func fetch(request: URLRequest) async throws -> String {
        #if canImport(FoundationNetworking)
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data ?? Data())
                }
            }.resume()
        }
        #else
        let (data, _) = try await urlSession.data(for: request)
        return String(data: data, encoding: .utf8) ?? ""
        #endif
    }
}

#if DEBUG

struct HTTPClientMock: HTTPClient {
    let html: String

    func fetch(request: URLRequest) async throws -> String {
        html
    }
}

#endif
