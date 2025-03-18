//
//  MovieCell.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import UIKit

class MovieCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .bold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let posterImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    contentView.addSubview(posterImageView)
    contentView.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      posterImageView.widthAnchor.constraint(equalToConstant: 80),
      posterImageView.heightAnchor.constraint(equalToConstant: 120),
      
      titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func configure(with movie: Movie) {
    titleLabel.text = movie.title
    
    // Load image using your preferred image loading library
    // Example with Kingfisher:
    // if let url = URL(string: movie.posterPath) {
    //     posterImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
    // }
  }
}
