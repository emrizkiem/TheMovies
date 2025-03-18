//
//  MovieRepository.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift

protocol MovieRepositoryProtocol {
  func getMovies(page: Int) -> Observable<MovieList>
  func refreshMovies(page: Int) -> Observable<MovieList>
  func clearLocalCache() -> Completable
}

final class MovieRepository: MovieRepositoryProtocol {
  private let remoteDataSource: MovieRemoteDataSource
  private let localDataSource: MovieLocalDataSource
  private let disposeBag = DisposeBag()
  
  init(
    remoteDataSource: MovieRemoteDataSource,
    localDataSource: MovieLocalDataSource
  ) {
    self.remoteDataSource = remoteDataSource
    self.localDataSource = localDataSource
  }
  
  func getMovies(page: Int) -> Observable<MovieList> {
    return localDataSource.getMovies()
      .flatMap { movies -> Observable<MovieList> in
        if movies.isEmpty {
          return self.fetchFromRemoteAndSaveToLocal(page: page)
        } else {
          print("Data diambil dari lokal storage")
          return Observable.just(MovieList(page: 1, totalPages: 1, totalResults: movies.count, results: movies))
        }
      }
      .catch { error in
        print("Error saat mengakses lokal storage: \(error.localizedDescription)")
        return self.fetchFromRemoteAndSaveToLocal(page: page)
      }
  }
  
  func refreshMovies(page: Int) -> Observable<MovieList> {
    return fetchFromRemoteAndSaveToLocal(page: page)
  }
  
  private func fetchFromRemoteAndSaveToLocal(page: Int) -> Observable<MovieList> {
    return remoteDataSource.fetchMovies(page: page)
      .do(onNext: { [weak self] movieList in
        guard let self = self else { return }
        self.localDataSource.saveMovies(movieList.results)
          .subscribe(onCompleted: {
            print("Data berhasil disimpan ke lokal storage")
          }, onError: { error in
            print("Error saat menyimpan ke lokal storage: \(error.localizedDescription)")
          })
          .disposed(by: self.disposeBag)
      })
      .catch { error in
        print("Error saat mengambil data dari remote: \(error.localizedDescription)")
        return self.localDataSource.getMovies().map { movies in
          return MovieList(page: 1, totalPages: 1, totalResults: movies.count, results: movies)
        }
      }
  }
  
  func clearLocalCache() -> Completable {
    return localDataSource.clearAllMovies()
      .do(onError: { error in
        print("Error saat menghapus local cache: \(error.localizedDescription)")
      }, onCompleted: {
        print("Local cache berhasil dihapus")
      })
  }
}
