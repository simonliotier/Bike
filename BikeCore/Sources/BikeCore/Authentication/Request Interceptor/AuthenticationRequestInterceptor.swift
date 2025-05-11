import Alamofire
import Foundation

/// Adapt and retry Alamofire requests for authentication.
final class AuthenticationRequestInterceptor: RequestInterceptor, Sendable {
    let authenticator: Authenticator

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void) {
        Task {
            do {
                let accessToken = try await authenticator.accessToken
                var request = urlRequest
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                completion(.success(request))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping (RetryResult) -> Void) {
        completion(request.retryCount < 3 ? .retryWithDelay(1.0) : .doNotRetry)
    }
}
