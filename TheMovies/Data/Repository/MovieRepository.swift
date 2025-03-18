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
  func searchMovies(query: String, page: Int) -> Observable<MovieList>
  func clearLocalCache() -> Completable
}

final class MovieRepository: MovieRepositoryProtocol {
  private let remoteDataSource: MovieRemoteDataSource
  private let localDataSource: MovieLocalDataSource
  private let disposeBag = DisposeBag()
  private var isManualClearOperation = false
  private var remotePageInfo: (totalPages: Int, totalResults: Int) = (1, 0)
  private var cachedPages = Set<Int>()
  
  init(
    remoteDataSource: MovieRemoteDataSource,
    localDataSource: MovieLocalDataSource
  ) {
    self.remoteDataSource = remoteDataSource
    self.localDataSource = localDataSource
  }
  
  func getMovies(page: Int) -> Observable<MovieList> {
    if isManualClearOperation {
      return Observable.just(MovieList(page: 1, totalPages: 1, totalResults: 0, results: []))
    }
    
    return localDataSource.getMoviesForPage(page: page)
      .flatMap { [weak self] movies -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        
        if movies.isEmpty {
          return self.fetchFromRemoteAndSaveToLocal(page: page)
        } else {
          print("Data halaman \(page) diambil dari Core Data")
          return Observable.just(MovieList(
            page: page,
            totalPages: self.remotePageInfo.totalPages,
            totalResults: self.remotePageInfo.totalResults,
            results: movies
          ))
        }
      }
      .catch { [weak self] error in
        guard let self = self else { return Observable.empty() }
        print("Error saat mengakses Core Data: \(error.localizedDescription)")
        return self.fetchFromRemoteAndSaveToLocal(page: page)
      }
  }
  
  func refreshMovies(page: Int) -> Observable<MovieList> {
    cachedPages.remove(page)
    return fetchFromRemoteAndSaveToLocal(page: page)
  }
  
  private func fetchFromRemoteAndSaveToLocal(page: Int) -> Observable<MovieList> {
    return remoteDataSource.fetchMovies(page: page)
      .do(onNext: { [weak self] movieList in
        guard let self = self else { return }
        
        self.remotePageInfo = (movieList.totalPages, movieList.totalResults)
        self.localDataSource.saveMovies(movieList.results, page: page)
          .subscribe(onCompleted: {
            print("Data halaman \(page) berhasil disimpan ke Core Data")
            self.cachedPages.insert(page)
          }, onError: { error in
            print("Error saat menyimpan halaman \(page) ke Core Data: \(error.localizedDescription)")
          })
          .disposed(by: self.disposeBag)
      })
      .catch { [weak self] error in
        guard let self = self else { return Observable.empty() }
        print("Error saat mengambil data dari remote: \(error.localizedDescription)")
        return self.localDataSource.getMoviesForPage(page: page).map { movies in
          return MovieList(
            page: page,
            totalPages: self.remotePageInfo.totalPages,
            totalResults: self.remotePageInfo.totalResults,
            results: movies
          )
        }
      }
  }
  
  func searchMovies(query: String, page: Int) -> Observable<MovieList> {
    return remoteDataSource.searchMovies(query: query, page: page)
      .catch { error in
        print("Error saat mencari movie: \(error.localizedDescription)")
        return Observable.empty()
      }
  }
  
  func clearLocalCache() -> Completable {
    self.isManualClearOperation = true
    self.cachedPages.removeAll()
    return localDataSource.clearAllMovies()
      .do(onError: { [weak self] error in
        print("Error saat menghapus local cache: \(error.localizedDescription)")
        self?.isManualClearOperation = false
      }, onCompleted: { [weak self] in
        print("Local cache berhasil dihapus")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self?.isManualClearOperation = false
        }
      })
  }
}
