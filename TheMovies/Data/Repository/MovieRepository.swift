//
//  MovieRepository.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift

protocol MovieRepositoryProtocol {
  func getMovies(page: Int) -> Observable<MovieList>
}

final class MovieRepository: MovieRepositoryProtocol {
  private let remoteDataSource: MovieRemoteDataSource
  private let localDataSource: MovieLocalDataSource
  
  init(
    remoteDataSource: MovieRemoteDataSource,
    localDataSource: MovieLocalDataSource
  ) {
    self.remoteDataSource = remoteDataSource
    self.localDataSource = localDataSource
  }
  
  func getMovies(page: Int) -> Observable<MovieList> {
    return remoteDataSource.fetchMovies(page: page)
      .do(onNext: { [weak self] movieList in
        self?.localDataSource.saveMovies(movieList.results)
          .subscribe()
          .disposed(by: DisposeBag())
      })
      .catch { _ in
        self.localDataSource.getMovies().map { movies in
          return MovieList(page: 1, totalPages: 1, totalResults: movies.count, results: movies)
        }
      }
  }
}

