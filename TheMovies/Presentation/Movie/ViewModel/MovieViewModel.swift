//
//  MovieViewModel.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import RxSwift
import RxCocoa

final class MovieViewModel {
  let loadTrigger = PublishRelay<Void>()
  let loadMoreTrigger = PublishRelay<Void>()
  let refreshTrigger = PublishRelay<Void>()
  let clearCacheTrigger = PublishRelay<Void>()
  let movies = BehaviorRelay<[Movie]>(value: [])
  let isLoading = BehaviorRelay<Bool>(value: false)
  let error = PublishRelay<String>()
  let searchTrigger = BehaviorRelay<String>(value: "")
  
  private let useCase: MovieUseCaseProtocol
  private let disposeBag = DisposeBag()
  private var currentPage = 1
  private var totalPages = 1
  private var isLoadingMore = false
  private var isSearchMode = false
  private var lastSearchQuery = ""
  private var searchPage = 1
  private var searchTotalPages = 1
  
  init(useCase: MovieUseCaseProtocol) {
    self.useCase = useCase
    
    setupBindings()
  }
  
  private func setupBindings() {
    loadTrigger
      .do(onNext: { [weak self] _ in
        self?.isLoading.accept(true)
        self?.currentPage = 1
      })
      .flatMapLatest { [weak self] _ -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.getMovies(page: self.currentPage)
          .catch { error in
            self.error.accept(error.localizedDescription)
            return Observable.empty()
          }
      }
      .do(onNext: { [weak self] list in
        self?.totalPages = list.totalPages
        self?.isLoading.accept(false)
      })
      .map { $0.results }
      .bind(to: movies)
      .disposed(by: disposeBag)
    
    searchTrigger
      .skip(1)
      .distinctUntilChanged()
      .do(onNext: { [weak self] query in
        self?.isLoading.accept(true)
        self?.isSearchMode = query.isEmpty ? false : true
        self?.lastSearchQuery = query
        self?.searchPage = 1
        
        if query.isEmpty {
          self?.currentPage = 1
          self?.loadTrigger.accept(())
          return
        }
      })
      .filter { !$0.isEmpty }
      .flatMapLatest { [weak self] query -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.searchMovies(query: query, page: self.searchPage)
          .catch { error in
            self.error.accept(error.localizedDescription)
            self.isLoading.accept(false)
            return Observable.empty()
          }
      }
      .do(onNext: { [weak self] list in
        self?.searchTotalPages = list.totalPages
        self?.isLoading.accept(false)
      })
      .map { $0.results }
      .bind(to: movies)
      .disposed(by: disposeBag)
    
    loadMoreTrigger
      .filter { [weak self] _ in
        guard let self = self else { return false }
        if self.isSearchMode {
          return !self.isLoadingMore && self.searchPage < self.searchTotalPages
        } else {
          return !self.isLoadingMore && self.currentPage < self.totalPages
        }
      }
      .do(onNext: { [weak self] _ in
        self?.isLoadingMore = true
        if self?.isSearchMode == true {
          self?.searchPage += 1
        } else {
          self?.currentPage += 1
        }
      })
      .flatMapLatest { [weak self] _ -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        
        if self.isSearchMode {
          return self.useCase.searchMovies(query: self.lastSearchQuery, page: self.searchPage)
            .catch { error in
              self.error.accept(error.localizedDescription)
              self.isLoadingMore = false
              return Observable.empty()
            }
        } else {
          return self.useCase.getMovies(page: self.currentPage)
            .catch { error in
              self.error.accept(error.localizedDescription)
              self.isLoadingMore = false
              return Observable.empty()
            }
        }
      }
      .do(onNext: { [weak self] list in
        if self?.isSearchMode == true {
          self?.searchTotalPages = list.totalPages
        } else {
          self?.totalPages = list.totalPages
        }
        self?.isLoadingMore = false
      })
      .map { [weak self] list in
        guard let self = self else { return [] }
        return self.movies.value + list.results
      }
      .bind(to: movies)
      .disposed(by: disposeBag)
    
    refreshTrigger
      .do(onNext: { [weak self] _ in
        self?.isLoading.accept(true)
        if self?.isSearchMode == true {
          self?.searchPage = 1
        } else {
          self?.currentPage = 1
        }
      })
      .flatMapLatest { [weak self] _ -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        
        if self.isSearchMode {
          return self.useCase.searchMovies(query: self.lastSearchQuery, page: 1)
            .catch { error in
              self.error.accept(error.localizedDescription)
              return Observable.empty()
            }
        } else {
          return self.useCase.refreshMovies(page: 1)
            .catch { error in
              self.error.accept(error.localizedDescription)
              return Observable.empty()
            }
        }
      }
      .do(onNext: { [weak self] list in
        if self?.isSearchMode == true {
          self?.searchTotalPages = list.totalPages
        } else {
          self?.totalPages = list.totalPages
        }
        self?.isLoading.accept(false)
      })
      .map { $0.results }
      .bind(to: movies)
      .disposed(by: disposeBag)
    
    clearCacheTrigger
      .flatMapLatest { [weak self] _ -> Observable<Void> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.clearCache()
          .andThen(Observable.just(()))
          .catch { error in
            self.error.accept("Failed to clear cache: \(error.localizedDescription)")
            return Observable.empty()
          }
      }
      .subscribe(onNext: { [weak self] _ in
        self?.currentPage = 1
        self?.totalPages = 1
        self?.movies.accept([])
      })
      .disposed(by: disposeBag)
  }
}
