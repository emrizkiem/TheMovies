//
//  MovieDetailViewModel.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import RxSwift
import RxCocoa

final class MovieDetailViewModel {
  private let movieIdRelay = BehaviorRelay<Int?>(value: nil)
  private let movieDetailRelay = BehaviorRelay<MovieDetail?>(value: nil)
  private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
  private let errorRelay = PublishRelay<String>()
  
  private let useCase: MovieUseCaseProtocol
  private let disposeBag = DisposeBag()
  private let movieId: Int
  
  init(useCase: MovieUseCaseProtocol, movieId: Int) {
    self.useCase = useCase
    self.movieId = movieId
    setupBindings()
  }
  
  func loadMovieDetail(id: Int) {
    movieIdRelay.accept(id)
  }
  
  func getMovieDetail() -> Driver<MovieDetail?> {
    return movieDetailRelay.asDriver()
  }
  
  func isLoading() -> Driver<Bool> {
    return isLoadingRelay.asDriver()
  }
  
  func setError() -> Driver<String> {
    return errorRelay.asDriver(onErrorJustReturn: "Unknown error occurred")
  }
  
  private func setupBindings() {
    movieIdRelay
      .compactMap { $0 }
      .distinctUntilChanged()
      .do(onNext: { [weak self] _ in
        self?.isLoadingRelay.accept(true)
      })
      .flatMapLatest { [weak self] id -> Observable<Result<MovieDetail, Error>> in
        guard let self = self else { return Observable.empty() }
        
        return self.useCase.detailMovies(id)
          .map { Result.success($0) }
          .catch { error -> Observable<Result<MovieDetail, Error>> in
            return Observable.just(Result.failure(error))
          }
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] result in
        self?.isLoadingRelay.accept(false)
        
        switch result {
        case .success(let movieDetail):
          self?.movieDetailRelay.accept(movieDetail)
        case .failure(let error):
          self?.errorRelay.accept(error.localizedDescription)
        }
      })
      .disposed(by: disposeBag)
  }
}
