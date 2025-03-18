//
//  MovieViewModel.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import RxSwift
import RxCocoa

final class MovieViewModel {
  private let moviesRelay = BehaviorRelay<[Movie]>(value: [])
  private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
  private let errorRelay = PublishRelay<String>()
  private let loadTriggerRelay = PublishRelay<Void>()
  private let loadMoreTriggerRelay = PublishRelay<Void>()
  private let refreshTriggerRelay = PublishRelay<Void>()
  private let clearCacheTriggerRelay = PublishRelay<Void>()
  private let searchTriggerRelay = BehaviorRelay<String>(value: "")
  
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
  
  func load() {
    loadTriggerRelay.accept(())
  }
  
  func loadMore() {
    loadMoreTriggerRelay.accept(())
  }
  
  func refresh() {
    refreshTriggerRelay.accept(())
  }
  
  func clearCache() {
    clearCacheTriggerRelay.accept(())
  }
  
  func search(query: String) {
    searchTriggerRelay.accept(query)
  }
  
  func getMovies() -> Driver<[Movie]> {
    return moviesRelay.asDriver()
  }
  
  func isLoading() -> Driver<Bool> {
    return isLoadingRelay.asDriver()
  }
  
  func setError() -> Driver<String> {
    return errorRelay.asDriver(onErrorJustReturn: "Unknown error occurred")
  }
  
  private func setupBindings() {
    setupLoadBinding()
    setupSearchBinding()
    setupRefreshBinding()
    setupLoadMoreBinding()
    setupClearCacheBinding()
  }
  
  private func setupLoadBinding() {
    loadTriggerRelay
      .do(onNext: { [weak self] _ in
        self?.isLoadingRelay.accept(true)
        self?.currentPage = 1
      })
      .flatMapLatest { [weak self] _ -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.getMovies(page: self.currentPage)
          .catch { error in
            self.errorRelay.accept(error.localizedDescription)
            return Observable.empty()
          }
      }
      .do(onNext: { [weak self] list in
        self?.totalPages = list.totalPages
        self?.isLoadingRelay.accept(false)
      })
      .map { $0.results }
      .bind(to: moviesRelay)
      .disposed(by: disposeBag)
  }
  
  private func setupSearchBinding() {
    searchTriggerRelay
      .skip(1)
      .distinctUntilChanged()
      .do(onNext: { [weak self] query in
        self?.isLoadingRelay.accept(true)
        self?.isSearchMode = query.isEmpty ? false : true
        self?.lastSearchQuery = query
        self?.searchPage = 1
        
        if query.isEmpty {
          self?.currentPage = 1
          self?.loadTriggerRelay.accept(())
          return
        }
      })
      .filter { !$0.isEmpty }
      .flatMapLatest { [weak self] query -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.searchMovies(query: query, page: self.searchPage)
          .catch { error in
            self.errorRelay.accept(error.localizedDescription)
            self.isLoadingRelay.accept(false)
            return Observable.empty()
          }
      }
      .do(onNext: { [weak self] list in
        self?.searchTotalPages = list.totalPages
        self?.isLoadingRelay.accept(false)
      })
      .map { $0.results }
      .bind(to: moviesRelay)
      .disposed(by: disposeBag)
  }
  
  private func setupRefreshBinding() {
    refreshTriggerRelay
      .do(onNext: { [weak self] _ in
        self?.isLoadingRelay.accept(true)
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
              self.errorRelay.accept(error.localizedDescription)
              return Observable.empty()
            }
        } else {
          return self.useCase.refreshMovies(page: 1)
            .catch { error in
              self.errorRelay.accept(error.localizedDescription)
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
        self?.isLoadingRelay.accept(false)
      })
      .map { $0.results }
      .bind(to: moviesRelay)
      .disposed(by: disposeBag)
  }
  
  private func setupLoadMoreBinding() {
    loadMoreTriggerRelay
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
              self.errorRelay.accept(error.localizedDescription)
              self.isLoadingMore = false
              return Observable.empty()
            }
        } else {
          return self.useCase.getMovies(page: self.currentPage)
            .catch { error in
              self.errorRelay.accept(error.localizedDescription)
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
        return self.moviesRelay.value + list.results
      }
      .bind(to: moviesRelay)
      .disposed(by: disposeBag)
  }
  
  private func setupClearCacheBinding() {
    clearCacheTriggerRelay
      .flatMapLatest { [weak self] _ -> Observable<Void> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.clearCache()
          .andThen(Observable.just(()))
          .catch { error in
            self.errorRelay.accept("Failed to clear cache: \(error.localizedDescription)")
            return Observable.empty()
          }
      }
      .subscribe(onNext: { [weak self] _ in
        self?.currentPage = 1
        self?.totalPages = 1
        self?.moviesRelay.accept([])
      })
      .disposed(by: disposeBag)
  }
}
