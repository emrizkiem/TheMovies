//
//  MovieViewController.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MovieViewController: UIViewController {
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    return refreshControl
  }()
  
  private let viewModel: MovieViewModel
  private let disposeBag = DisposeBag()
  
  init(viewModel: MovieViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
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
    title = "Movies"
    view.backgroundColor = .white
    
    view.addSubview(tableView)
    view.addSubview(activityIndicator)
    tableView.addSubview(refreshControl)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  private func setupBindings() {
    viewModel.movies
      .bind(to: tableView.rx.items(cellIdentifier: "MovieCell", cellType: MovieCell.self)) { (row, movie, cell) in
        cell.configure(with: movie)
      }
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .bind(to: activityIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    refreshControl.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.loadTrigger)
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
    
    tableView.rx.willDisplayCell
      .subscribe(onNext: { [weak self] cell, indexPath in
        guard let self = self else { return }
        let lastRow = self.viewModel.movies.value.count - 1
        if indexPath.row == lastRow {
          self.viewModel.loadMoreTrigger.accept(())
        }
      })
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        let movie = self.viewModel.movies.value[indexPath.row]
        self.showMovieDetail(movie: movie)
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
    // let detailVC = MovieDetailViewController(movie: movie)
    // navigationController?.pushViewController(detailVC, animated: true)
  }
}
