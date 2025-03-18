//
//  MovieViewController.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MovieViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    return refreshControl
  }()
  
  private let viewModel: MovieViewModel
  private let disposeBag = DisposeBag()
  
  init(viewModel: MovieViewModel) {
    self.viewModel = viewModel
    super.init(nibName: "MovieViewController", bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
    
    viewModel.loadTrigger.accept(())
  }
  
  private func setupUI() {
    title = "Hey, Welcome Back!"
    let navBarColor = UIColor(red: 0.788, green: 0.188, blue: 0.188, alpha: 1.0)
    
    if #available(iOS 15.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = navBarColor
      appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      navigationController?.navigationBar.standardAppearance = appearance
      navigationController?.navigationBar.scrollEdgeAppearance = appearance
    } else {
      navigationController?.navigationBar.barTintColor = navBarColor
      navigationController?.navigationBar.isTranslucent = false
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    collectionView.register(MovieCell.nib(), forCellWithReuseIdentifier: MovieCell.identifier)
    collectionView.backgroundColor = .systemGray6
    collectionView.alwaysBounceVertical = true
    collectionView.refreshControl = refreshControl
    
    searchBar.barTintColor = UIColor(red: 145.0, green: 34.0, blue: 40.0, alpha: 1.0)
    searchBar.tintColor = .black
    
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let screenWidth = UIScreen.main.bounds.width
      let itemWidth = (screenWidth - 30) / 2
      layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.4)
    }
  }
  
  private func setupBindings() {
    viewModel.movies
      .bind(to: collectionView.rx.items(cellIdentifier: MovieCell.identifier, cellType: MovieCell.self)) { (row, movie, cell) in
        cell.configure(with: movie)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .bind(to: activityIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    refreshControl.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.refreshTrigger)
      .disposed(by: disposeBag)
    
    viewModel.error
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] error in
        self?.showAlert(message: error)
        self?.refreshControl.endRefreshing()
      })
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .subscribe(onNext: { [weak self] _ in
        self?.refreshControl.endRefreshing()
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.willDisplayCell
      .subscribe(onNext: { [weak self] cell, indexPath in
        guard let self = self else { return }
        let lastRow = self.viewModel.movies.value.count - 1
        if indexPath.row == lastRow {
          self.viewModel.loadMoreTrigger.accept(())
        }
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        let movie = self.viewModel.movies.value[indexPath.row]
        self.showMovieDetail(movie: movie)
      })
      .disposed(by: disposeBag)
    
    searchBar.rx.text
      .orEmpty
      .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .bind(to: viewModel.searchTrigger)
      .disposed(by: disposeBag)
      
    searchBar.rx.searchButtonClicked
      .subscribe(onNext: { [weak self] in
        self?.searchBar.resignFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func showAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  private func showMovieDetail(movie: Movie) {
    // Implement navigation to movie detail screen
    // Example:
    // let detailVM = MovieDetailViewModel(movie: movie, movieRepository: MovieRepository())
    // let detailVC = MovieDetailViewController(viewModel: detailVM)
    // navigationController?.pushViewController(detailVC, animated: true)
  }
}
