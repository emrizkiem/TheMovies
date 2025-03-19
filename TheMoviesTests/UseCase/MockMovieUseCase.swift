//
//  MockMovieUseCase.swift
//  TheMoviesTests
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import RxSwift
@testable import TheMovies

class MockMovieUseCase: MovieUseCaseProtocol {
  var clearCacheResult: Completable = .empty()
  var getMoviesResult: Observable<MovieList> = .just(MockData.dummyMovieList)
  var searchMoviesResult: Observable<MovieList> = .just(MockData.dummyMovieList)
  var refreshMoviesResult: Observable<MovieList> = .just(MockData.dummyMovieList)
  var detailMoviesResult: Observable<MovieDetail> = .just(MockData.dummyMovieDetail)
  
  func getMovies(page: Int) -> Observable<MovieList> {
    return getMoviesResult
  }
  
  func searchMovies(query: String, page: Int) -> Observable<MovieList> {
    return searchMoviesResult
  }
  
  func refreshMovies(page: Int) -> Observable<MovieList> {
    return refreshMoviesResult
  }
  
  func detailMovies(_ id: Int) -> Observable<MovieDetail> {
    return detailMoviesResult
  }
  
  func clearCache() -> Completable {
    return clearCacheResult
  }
}
