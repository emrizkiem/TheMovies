//
//  MovieUseCase.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift

protocol MovieUseCaseProtocol {
  func execute(page: Int) -> Observable<MovieList>
}

final class MovieUseCase: MovieUseCaseProtocol {
  private let repository: MovieRepositoryProtocol
  
  init(repository: MovieRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(page: Int) -> Observable<MovieList> {
    return repository.getMovies(page: page)
  }
}
