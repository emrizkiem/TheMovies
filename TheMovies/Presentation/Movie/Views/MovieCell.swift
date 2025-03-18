//
//  MovieCell.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var ratingStackView: UIStackView!
  
  static let identifier = "MovieCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
  }
  
  private func setupUI() {
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 4
    layer.shadowOpacity = 0.1
    layer.masksToBounds = false
  }
  
  func configure(with movie: Movie) {
    titleLabel.text = movie.title
    releaseDateLabel.text = movie.releaseDate
    
    configureRating(movie.voteAverage)
    
    if let posterPath = movie.posterPath, let url = URL(string: NetworkConfig.imageBaseURL + posterPath) {
      posterImageView.kf.setImage(with: url)
      posterImageView.contentMode = .scaleAspectFill
    }
  }
  
  private func configureRating(_ rating: Double) {
    let starRating = rating / 2.0
    
    for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
      if let starImageView = view as? UIImageView {
        if Double(index) + 0.5 <= starRating {
          starImageView.image = UIImage(systemName: "star.fill")
        } else if Double(index) < starRating {
          starImageView.image = UIImage(systemName: "star.leadinghalf.fill")
        } else {
          starImageView.image = UIImage(systemName: "star")
        }
      }
    }
  }
  
  static func nib() -> UINib {
    return UINib(nibName: "MovieCell", bundle: nil)
  }
}
