//
//  MovieDetailViewController.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class MovieDetailViewController: UIViewController {
  
  @IBOutlet weak var navigationView: UIView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var backdropImageView: UIImageView!
  @IBOutlet weak var genreStackView: UIStackView!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var ratingStackView: UIStackView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var imdbButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private let viewModel: MovieDetailViewModel
  private let disposeBag = DisposeBag()
  private var movieId: Int = 0
  private var currentMovieDetail: MovieDetail?
  
  init(viewModel: MovieDetailViewModel, movieId: Int) {
    self.viewModel = viewModel
    self.movieId = movieId
    super.init(nibName: "MovieDetailViewController", bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
    viewModel.loadMovieDetail(id: movieId)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = true
  }
  
  private func setupUI() {
    navigationView.backgroundColor = UIColor(red: 0.788, green: 0.188, blue: 0.188, alpha: 1.0)
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    
    imdbButton.layer.cornerRadius = 8
    imdbButton.layer.masksToBounds = true
    imdbButton.backgroundColor = UIColor.white
    imdbButton.setTitleColor(UIColor.red, for: .normal)
    imdbButton.layer.borderColor = UIColor.red.cgColor
    imdbButton.layer.borderWidth = 1
  }
  
  private func bindViewModel() {
    viewModel.getMovieDetail()
      .drive(onNext: { [weak self] movieDetail in
        guard let self = self, let movieDetail = movieDetail else { return }
        self.currentMovieDetail = movieDetail
        self.updateUI(with: movieDetail)
      })
      .disposed(by: disposeBag)
    
    viewModel.isLoading()
      .drive(onNext: { [weak self] isLoading in
        self?.updateLoadingState(isLoading)
      })
      .disposed(by: disposeBag)
    
    viewModel.setError()
      .drive(onNext: { [weak self] errorMessage in
        self?.showError(message: errorMessage)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateUI(with movieDetail: MovieDetail) {
    titleLabel.text = movieDetail.title
    if let backdropPath = movieDetail.backdropPath, let url = URL(string: NetworkConfig.imageBaseURL + backdropPath) {
      backdropImageView.kf.setImage(with: url)
      backdropImageView.contentMode = .scaleAspectFill
    }
    updateGenres(movieDetail.genres)
    releaseDateLabel.text = movieDetail.releaseDate
    updateRating(movieDetail.voteAverage)
    descriptionLabel.text = movieDetail.overview
    imdbButton.addTarget(self, action: #selector(openIMDB), for: .touchUpInside)
  }
  
  private func updateGenres(_ genres: [Genre]) {
    genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for genre in genres {
      let genreView = GenreView(frame: .zero)
      genreView.configure(with: genre.name)
      genreStackView.addArrangedSubview(genreView)
    }
  }
  
  private func updateRating(_ rating: Double) {
    ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    let starCount = Int(rating / 2)
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
    
    for _ in 0..<starCount {
      let starImage = UIImage(systemName: "star.fill", withConfiguration: config)
      let starImageView = UIImageView(image: starImage)
      starImageView.tintColor = .systemRed
      starImageView.contentMode = .scaleAspectFit
      ratingStackView.addArrangedSubview(starImageView)
    }
    
    for _ in starCount..<5 {
      let starImage = UIImage(systemName: "star", withConfiguration: config)
      let starImageView = UIImageView(image: starImage)
      starImageView.tintColor = .systemRed
      starImageView.contentMode = .scaleAspectFit
      ratingStackView.addArrangedSubview(starImageView)
    }
  }
  
  private func updateLoadingState(_ isLoading: Bool) {
    activityIndicator.isHidden = !isLoading
  }
  
  private func showError(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  @objc private func backButtonTapped() {
    navigationController?.popViewController(animated: true)
  }
  
  @objc private func openIMDB() {
    if let imdbId = currentMovieDetail?.imdbID, !imdbId.isEmpty,
      let imdbURL = URL(string: NetworkConfig.baseURLTMDB + imdbId) {
      let webViewController = WebViewController(url: imdbURL, title: "\(titleLabel.text ?? "Movie")")
      navigationController?.pushViewController(webViewController, animated: true)
    } else {
      let alert = UIAlertController(title: "Information", message: "IMDb ID not available for this movie.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
  }
}
