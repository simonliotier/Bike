import Alamofire
import Foundation
@preconcurrency import OAuth2

/// Adapt and retry Alamofire requests for authentication.
///
/// Inspired by [OAuth2 wiki](https://github.com/p2/OAuth2/wiki/Alamofire-5).
final class AuthenticationRequestInterceptor: RequestInterceptor {
    let loader: OAuth2DataLoader

    init(oauth2: OAuth2) {
        loader = OAuth2DataLoader(oauth2: oauth2)
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard loader.oauth2.accessToken != nil else {
            completion(.success(urlRequest))
            return
        }

        do {
            let adaptedURLRequest = try urlRequest.signed(with: loader.oauth2)
            completion(.success(adaptedURLRequest))
        } catch {
            completion(.failure(error))
        }
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              let urlRequest = request.request else {
            completion(.doNotRetry)
            return
        }

        var dataRequest = OAuth2DataRequest(request: urlRequest, callback: { _ in })
        dataRequest.context = completion
        loader.enqueue(request: dataRequest)
        loader.attemptToAuthorize { authParams, _ in
            self.loader.dequeueAndApply { request in
                if let completion = request.context as? (RetryResult) -> Void {
                    completion(authParams != nil ? .retry : .doNotRetry)
                }
            }
        }
    }
}
