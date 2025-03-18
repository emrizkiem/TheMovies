//
//  MovieDetail.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import Foundation

struct MovieDetail: Decodable {
  let backdropPath: String?
  let genres: [Genre]
  let id: Int
  let imdbID: String
  let overview: String
  let posterPath: String?
  let releaseDate: String
  let title: String
  let voteAverage: Double
  
  enum CodingKeys: String, CodingKey {
    case backdropPath = "backdrop_path"
    case imdbID = "imdb_id"
    case posterPath = "poster_path"
    case releaseDate = "release_date"
    case voteAverage = "vote_average"
    case genres, title, overview, id
  }
}

struct Genre: Decodable {
  let id: Int
  let name: String
}
