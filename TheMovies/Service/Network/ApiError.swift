//
//  ApiError.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Foundation

enum ApiError: Error {
  case invalidURL
  case invalidResponse
  case noData
  case decodingError
  case networkError(Error)
  case serverError(Int)
  case unauthorized
  case unknown
  
  var errorDescription: String {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid response"
    case .noData:
      return "No data received"
    case .decodingError:
      return "Error decoding data"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .serverError(let statusCode):
      return "Server error with status code: \(statusCode)"
    case .unauthorized:
      return "Unauthorized access. Please check your API token"
    case .unknown:
      return "Unknown error occurred"
    }
  }
}
