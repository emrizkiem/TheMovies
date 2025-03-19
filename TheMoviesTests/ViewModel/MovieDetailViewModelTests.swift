//
//  MovieDetailViewModelTests.swift
//  TheMoviesTests
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import TheMovies

class MovieDetailViewModelTests: XCTestCase {
  
  var viewModel: MovieDetailViewModel!
  var mockUseCase: MockMovieUseCase!
  var scheduler: TestScheduler!
  var disposeBag: DisposeBag!
  let testMovieId = 696506
  
  override func setUp() {
    super.setUp()
    mockUseCase = MockMovieUseCase()
    viewModel = MovieDetailViewModel(useCase: mockUseCase, movieId: testMovieId)
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
  
  func testLoadMovieDetail_Success() {
    // Arrange
    let movieDetailObserver = scheduler.createObserver(MovieDetail?.self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    
    // Set expected movie detail in mock
    mockUseCase.detailMoviesResult = Observable.just(MockData.dummyMovieDetail)
    
    // Act
    viewModel.getMovieDetail()
      .drive(movieDetailObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.loadMovieDetail(id: testMovieId)
    scheduler.start()
    
    // Assert
    let expectedDetail = MockData.dummyMovieDetail
    
    XCTAssertEqual(movieDetailObserver.events.count, 2) // Initial nil + loaded data
    
    let loadedDetail = movieDetailObserver.events.last?.value.element
    XCTAssertNotNil(loadedDetail ?? [])
    XCTAssertEqual(loadedDetail??.id, expectedDetail.id)
    XCTAssertEqual(loadedDetail??.title, expectedDetail.title)
    
    // Check loading states
    XCTAssertEqual(loadingObserver.events.count, 3) // Initial false + true + false
    XCTAssertEqual(loadingObserver.events[0].value.element, false) // Initial state
    XCTAssertEqual(loadingObserver.events[1].value.element, true) // Loading started
    XCTAssertEqual(loadingObserver.events[2].value.element, false) // Loading completed
  }
  
  func testLoadMovieDetail_Error() {
    // Arrange
    let errorMessage = "Network error"
    mockUseCase.detailMoviesResult = Observable.error(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
    
    let errorObserver = scheduler.createObserver(String.self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    let movieDetailObserver = scheduler.createObserver(MovieDetail?.self)
    
    // Act
    viewModel.setError()
      .drive(errorObserver)
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(loadingObserver)
      .disposed(by: disposeBag)
    
    viewModel.getMovieDetail()
      .drive(movieDetailObserver)
      .disposed(by: disposeBag)
    
    viewModel.loadMovieDetail(id: testMovieId)
    scheduler.start()
    
    // Assert
    XCTAssertEqual(errorObserver.events.count, 1)
    XCTAssertEqual(errorObserver.events.first?.value.element, errorMessage)
    
    XCTAssertEqual(loadingObserver.events.count, 3) // Initial false + true + false
    XCTAssertEqual(loadingObserver.events[1].value.element, true)
    XCTAssertEqual(loadingObserver.events[2].value.element, false)
    
    // Movie detail should still be nil (initial value)
    XCTAssertEqual(movieDetailObserver.events.count, 1)
    XCTAssertNil(movieDetailObserver.events.first?.value.element ?? [])
  }
}
