//
//  MovieEntity+Mapping.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Foundation

extension Movie {
  init(entity: MovieEntity) {
    self.id = Int(entity.id)
    self.title = entity.title ?? ""
    self.overview = entity.overview ?? ""
    self.posterPath = entity.posterPath
    self.backdropPath = entity.backdropPath
    self.voteAverage = entity.voteAverage
    self.releaseDate = entity.releaseDate ?? ""
    self.genreIds = []
  }
}

extension MovieEntity {
  func toMovie() -> Movie {
    return Movie(entity: self)
  }
}
