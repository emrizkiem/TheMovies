//
//  NetworkEndpoints.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import Moya

enum NetworkEndpoints {
  case movie(page: Int)
  case movieDetail(id: Int)
  case searchMovie(query: String, page: Int)
}

extension NetworkEndpoints: TargetType {
  var baseURL: URL {
    guard let url = URL(string: NetworkConfig.baseURL) else {
      fatalError("Invalid base URL")
    }
    return url
  }
  
  var path: String {
    switch self {
    case .movie(let page):
      return "/discover/movie"
    case .movieDetail(let id):
      return "/movie/\(id)"
    case .searchMovie(let query, let page):
      return "/search/movie"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .movie,
        .movieDetail,
        .searchMovie:
        .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .movie(let page):
      return .requestParameters(
        parameters: ["page": page],
        encoding: URLEncoding.queryString
      )
    case .movieDetail(let id):
      return .requestParameters(
        parameters: [:],
        encoding: URLEncoding.queryString
      )
    case .searchMovie(let query, let page):
      return .requestParameters(
        parameters: ["query": query, "page": page],
        encoding: URLEncoding.queryString
      )
    }
  }
  
  var headers: [String : String]? {
    return [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer \(NetworkConfig.bearerToken)"
    ]
  }
  
  var sampleData: Data {
    return Data()
  }
}
