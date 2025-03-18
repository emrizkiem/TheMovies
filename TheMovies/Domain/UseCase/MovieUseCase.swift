//
//  MovieUseCase.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift

protocol MovieUseCaseProtocol {
  func getMovies(page: Int) -> Observable<MovieList>
  func refreshMovies(page: Int) -> Observable<MovieList>
  func searchMovies(query: String, page: Int) -> Observable<MovieList>
  func detailMovies(_ id: Int) -> Observable<MovieDetail>
  func clearCache() -> Completable
}

final class MovieUseCase: MovieUseCaseProtocol {
  private let repository: MovieRepositoryProtocol
  
  init(repository: MovieRepositoryProtocol) {
    self.repository = repository
  }
  
  func getMovies(page: Int) -> Observable<MovieList> {
    return repository.getMovies(page: page)
  }
  
  func refreshMovies(page: Int) -> Observable<MovieList> {
    return repository.refreshMovies(page: page)
  }
  
  func searchMovies(query: String, page: Int) -> Observable<MovieList> {
    return repository.searchMovies(query: query, page: page)
  }
  
  func detailMovies(_ id: Int) -> Observable<MovieDetail> {
    return repository.detailMovies(id)
  }
  
  func clearCache() -> Completable {
    return repository.clearLocalCache()
  }
}
