//
//  Movie.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Foundation

struct MovieList: Decodable {
  let page: Int
  let totalPages: Int
  let totalResults: Int
  let results: [Movie]
  
  enum CodingKeys: String, CodingKey {
    case page
    case totalPages = "total_pages"
    case totalResults = "total_results"
    case results
  }
}

struct Movie: Decodable {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let backdropPath: String?
  let voteAverage: Double
  let releaseDate: String
  let genreIds: [Int]
  
  var posterURL: URL? {
    guard let posterPath = posterPath else { return nil }
    return URL(string: "\(NetworkConfig.imageBaseURL)\(posterPath)")
  }
  
  var backdropURL: URL? {
    guard let backdropPath = backdropPath else { return nil }
    return URL(string: "\(NetworkConfig.imageBaseURL)\(backdropPath)")
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case overview
    case posterPath = "poster_path"
    case backdropPath = "backdrop_path"
    case voteAverage = "vote_average"
    case releaseDate = "release_date"
    case genreIds = "genre_ids"
  }
}
