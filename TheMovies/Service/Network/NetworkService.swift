//
//  NetworkService.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import Moya
import RxSwift

protocol NetworkServiceProtocol {
  func request<T: Decodable>(_ endpoint: NetworkEndpoints) -> Observable<T>
}

final class NetworkService: NetworkServiceProtocol {
  private let provider: MoyaProvider<NetworkEndpoints>
  
  init(provider: MoyaProvider<NetworkEndpoints> = MoyaProvider<NetworkEndpoints>(plugins: [NetworkLogger()])) {
    self.provider = provider
  }
  
  func request<T: Decodable>(_ endpoint: NetworkEndpoints) -> Observable<T> {
    return provider.rx.request(endpoint)
      .filterSuccessfulStatusCodes()
      .map(T.self)
      .asObservable()
      .catch { error in
        if let moyaError = error as? MoyaError {
          switch moyaError {
          case .statusCode(let response):
            if response.statusCode == 401 {
              return Observable<T>.error(ApiError.unauthorized)
            }
            return Observable<T>.error(ApiError.serverError(response.statusCode))
          case .underlying(let nsError, _):
            return Observable<T>.error(ApiError.networkError(nsError))
          default:
            return Observable<T>.error(ApiError.unknown)
          }
        }
        return Observable<T>.error(ApiError.unknown)
      }
  }
}
