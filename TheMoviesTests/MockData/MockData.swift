//
//  MockData.swift
//  TheMoviesTests
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import Foundation
@testable import TheMovies

struct MockData {
  static let dummyMovieList: MovieList = .init(
    page: 1,
    totalPages: 1,
    totalResults: 1,
    results: [
      Movie(
        id: 696506,
        title: "Mickey 17",
        overview: "Unlikely hero Mickey Barnes finds himself in the extraordinary circumstance of working for an employer who demands the ultimate commitment to the job… to die, for a living.",
        posterPath: "/edKpE9B5qN3e559OuMCLZdW1iBZ.jpg",
        backdropPath: "/qUc0Hol3eP74dbW4YyqT6oRLYgT.jpg",
        voteAverage: 7.02,
        releaseDate: "2025-02-28",
        genreIds: [878, 35, 12]
      )
    ]
  )
  
  static let dummyMovieDetail: MovieDetail = .init(
    backdropPath: "/qUc0Hol3eP74dbW4YyqT6oRLYgT.jpg",
    genres: [
      Genre(
        id: 878,
        name: "Science Fiction"
      ),
      Genre(
        id: 35,
        name: "Comedy"
      ),
      Genre(
        id: 12,
        name: "Adventure"
      ),
    ],
    id: 696506,
    imdbID: "tt12299608",
    overview: "Unlikely hero Mickey Barnes finds himself in the extraordinary circumstance of working for an employer who demands the ultimate commitment to the job… to die, for a living.",
    posterPath: "/edKpE9B5qN3e559OuMCLZdW1iBZ.jpg",
    releaseDate: "2025-02-28",
    title: "Mickey 17",
    voteAverage: 7.02
  )
}
