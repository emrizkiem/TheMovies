//
//  MovieViewModelTests.swift
//  TheMoviesTests
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import TheMovies

class MovieViewModelTests: XCTestCase {
  var viewModel: MovieViewModel!
  var mockUseCase: MockMovieUseCase!
  var scheduler: TestScheduler!
  var disposeBag: DisposeBag!
  
  override func setUp() {
    super.setUp()
    mockUseCase = MockMovieUseCase()
    viewModel = MovieViewModel(useCase: mockUseCase)
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()
  }
  
  override func tearDown() {
    viewModel = nil
    mockUseCase = nil
    scheduler = nil
    disposeBag = nil
    super.tearDown()
  }
  
  private func compareMovies(_ lhs: [Movie], _ rhs: [Movie]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    for (index, movie) in lhs.enumerated() {
      if movie.id != rhs[index].id {
        return false
      }
    }
    
    return true
  }
  
  func testGetMovies_Success() {
    // Arrange
    let moviesObserver = scheduler.createObserver([Movie].self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.load()
    scheduler.start()
    
    // Assert
    let expectedMovies = MockData.dummyMovieList.results
    
    XCTAssertEqual(moviesObserver.events.count, 2) // Initial empty value + loaded data
    XCTAssertEqual(moviesObserver.events.last?.value.element?.count, expectedMovies.count)
    XCTAssertEqual(moviesObserver.events.last?.value.element?.first?.id, expectedMovies.first?.id)
    
    XCTAssertEqual(loadingObserver.events.count, 3) // Initial false + true + false
    XCTAssertEqual(loadingObserver.events[1].value.element, true)
    XCTAssertEqual(loadingObserver.events[2].value.element, false)
  }
  
  func testGetMovies_Error() {
    // Arrange
    let errorMessage = "Network error"
    mockUseCase.getMoviesResult = Observable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
    
    let errorObserver = scheduler.createObserver(String.self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Act
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.load()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
    
    XCTAssertEqual(loadingObserver.events.count, 2) // Initial false + true
    XCTAssertEqual(loadingObserver.events[1].value.element, true)
  }
  
  func testSearchMovies_Success() {
    // Arrange
    let searchQuery = "Mickey"
    let moviesObserver = scheduler.createObserver([Movie].self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.search(query: searchQuery)
    scheduler.start()
    
    // Assert
    let expectedMovies = MockData.dummyMovieList.results
    
    XCTAssertEqual(moviesObserver.events.count, 2) // Initial empty value + search results
    XCTAssertEqual(moviesObserver.events.last?.value.element?.count, expectedMovies.count)
    XCTAssertEqual(moviesObserver.events.last?.value.element?.first?.id, expectedMovies.first?.id)
    
    XCTAssertEqual(loadingObserver.events.count, 3) // Initial false + true + false
    XCTAssertEqual(loadingObserver.events[1].value.element, true)
    XCTAssertEqual(loadingObserver.events[2].value.element, false)
  }
  
  func testSearchMovies_Error() {
    // Arrange
    let searchQuery = "Mickey"
    let errorMessage = "Search error"
    mockUseCase.searchMoviesResult = Observable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
    
    let errorObserver = scheduler.createObserver(String.self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Act
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.search(query: searchQuery)
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
    
    XCTAssertEqual(loadingObserver.events.count, 3) // Initial false + true + false (error handling sets loading to false)
    XCTAssertEqual(loadingObserver.events[1].value.element, true)
    XCTAssertEqual(loadingObserver.events[2].value.element, false)
  }
  
  func testSearchMovies_EmptyQuery() {
    // Arrange
    let moviesObserver = scheduler.createObserver([Movie].self)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    // First load regular movies
    viewModel.load()
    scheduler.start()
    
    // Then search with empty query (should reload regular movies)
    viewModel.search(query: "")
    scheduler.start()
    
    // Assert
    let expectedMovies = MockData.dummyMovieList.results
    
    XCTAssertEqual(moviesObserver.events.count, 3) // Initial empty + loaded data + reloaded data
    XCTAssertEqual(moviesObserver.events.last?.value.element?.count, expectedMovies.count)
  }
  
  func testRefresh_Success() {
    // Arrange
    let moviesObserver = scheduler.createObserver([Movie].self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    // First load normal data
    viewModel.load()
    scheduler.start()
    
    // Then refresh
    viewModel.refresh()
    scheduler.start()
    
    // Assert
    let expectedMovies = MockData.dummyMovieList.results
    
    XCTAssertEqual(moviesObserver.events.count, 3) // Initial empty + first load + refresh
    XCTAssertEqual(moviesObserver.events.last?.value.element?.count, expectedMovies.count)
    
    // Check if loading state changed correctly during refresh
    XCTAssertEqual(loadingObserver.events.count >= 5, true) // Initial false + true + false + true + false
    XCTAssertEqual(loadingObserver.events[3].value.element, true) // Refresh started
    XCTAssertEqual(loadingObserver.events[4].value.element, false) // Refresh completed
  }
  
  func testRefresh_Error() {
    // Arrange
    let errorMessage = "Refresh error"
    mockUseCase.refreshMoviesResult = Observable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
    
    let errorObserver = scheduler.createObserver(String.self)
    
    // Act
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    // First load normal data
    viewModel.load()
    scheduler.start()
    
    // Then refresh with error
    viewModel.refresh()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
  }
  
  func testLoadMore_Success() {
    // Arrange
    let moviesObserver = scheduler.createObserver([Movie].self)
    
    // Use a custom movie list with multiple pages
    let multiPageMovieList = MovieList(
      page: 1,
      totalPages: 3,
      totalResults: 60,
      results: MockData.dummyMovieList.results
    )
    
    let page2MovieList = MovieList(
      page: 2,
      totalPages: 3,
      totalResults: 60,
      results: [
        Movie(
          id: 123456,
          title: "Another Movie",
          overview: "Another movie overview",
          posterPath: "/path.jpg",
          backdropPath: "/backdrop.jpg",
          voteAverage: 8.0,
          releaseDate: "2025-03-15",
          genreIds: [28, 12]
        )
      ]
    )
    
    mockUseCase.getMoviesResult = Observable.just(multiPageMovieList)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    // First load page 1
    viewModel.load()
    scheduler.start()
    
    // Then prepare for load more
    mockUseCase.getMoviesResult = Observable.just(page2MovieList)
    
    // Load more
    viewModel.loadMore()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(moviesObserver.events.count, 3) // Initial empty + first load + load more
    
    // After load more, we should have combined results
    let combinedResults = moviesObserver.events.last?.value.element
    XCTAssertEqual(combinedResults?.count, 2) // 1 from first page + 1 from second page
    XCTAssertEqual(combinedResults?.first?.id, MockData.dummyMovieList.results.first?.id)
    XCTAssertEqual(combinedResults?.last?.id, 123456)
  }
  
  func testLoadMore_Error() {
    // Arrange
    let errorMessage = "Load more error"
    let moviesObserver = scheduler.createObserver([Movie].self)
    let errorObserver = scheduler.createObserver(String.self)
    
    // Use a custom movie list with multiple pages
    let multiPageMovieList = MovieList(
      page: 1,
      totalPages: 3,
      totalResults: 60,
      results: MockData.dummyMovieList.results
    )
    
    mockUseCase.getMoviesResult = Observable.just(multiPageMovieList)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    // First load page 1
    viewModel.load()
    scheduler.start()
    
    // Then prepare for load more with error
    mockUseCase.getMoviesResult = Observable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
    
    // Load more
    viewModel.loadMore()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
    
    // The movies array should still contain the original results
    let resultsAfterError = moviesObserver.events.last?.value.element
    XCTAssertEqual(resultsAfterError?.count, 1) // Only the original movie
  }
  
  func testClearCache_Success() {
    // Arrange
    let moviesObserver = scheduler.createObserver([Movie].self)
    
    // Act
    viewModel.getMovies()
      .drive(moviesObserver)
      .disposed(by: disposeBag)
    
    // First load data
    viewModel.load()
    scheduler.start()
    
    // Then clear cache
    viewModel.clearCache()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(moviesObserver.events.count, 3) // Initial empty + loaded data + cleared (empty)
    XCTAssertEqual(moviesObserver.events.last?.value.element?.count, 0) // Should be empty after clearing
  }
  
  func testClearCache_Error() {
    // Arrange
    let errorMessage = "Failed to clear cache: Cache error"
    mockUseCase.clearCacheResult = Completable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cache error"]))
    
    let errorObserver = scheduler.createObserver(String.self)
    
    // Act
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    viewModel.clearCache()
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
  }
}
