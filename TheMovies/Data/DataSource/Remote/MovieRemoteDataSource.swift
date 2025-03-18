//
//  MovieRemoteDataSource.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Moya
import RxSwift

protocol MovieRemoteDataSourceProtocol {
  func fetchMovies(page: Int) -> Observable<MovieList>
}

final class MovieRemoteDataSource: MovieRemoteDataSourceProtocol {
  private let networkService: NetworkServiceProtocol
  
  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
  
  func fetchMovies(page: Int) -> Observable<MovieList> {
    return networkService.request(.movie(page: page))
  }
}

