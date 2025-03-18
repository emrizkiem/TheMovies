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
  let movies = BehaviorRelay<[Movie]>(value: [])
  let isLoading = BehaviorRelay<Bool>(value: false)
  let error = PublishRelay<String>()
  
  private let useCase: GetMoviesUseCase
  private let disposeBag = DisposeBag()
  private var currentPage = 1
  private var totalPages = 1
  private var isLoadingMore = false
  
  init(useCase: GetMoviesUseCase) {
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
        return self.useCase.execute(page: self.currentPage)
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
    
    loadMoreTrigger
      .filter { [weak self] _ in
        guard let self = self else { return false }
        return !self.isLoadingMore && self.currentPage < self.totalPages
      }
      .do(onNext: { [weak self] _ in
        self?.isLoadingMore = true
        self?.currentPage += 1
      })
      .flatMapLatest { [weak self] _ -> Observable<MovieList> in
        guard let self = self else { return Observable.empty() }
        return self.useCase.execute(page: self.currentPage)
          .catch { error in
            self.error.accept(error.localizedDescription)
            self.isLoadingMore = false
            return Observable.empty()
          }
      }
      .do(onNext: { [weak self] list in
        self?.totalPages = list.totalPages
        self?.isLoadingMore = false
      })
      .map { [weak self] list in
        guard let self = self else { return [] }
        return self.movies.value + list.results
      }
      .bind(to: movies)
      .disposed(by: disposeBag)
  }
}
