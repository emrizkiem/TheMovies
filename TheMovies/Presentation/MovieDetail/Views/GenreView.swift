//
//  GenreView.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import UIKit

class GenreView: UIView {
  private let genreLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    layer.cornerRadius = 4
    layer.masksToBounds = true
    
    genreLabel.textColor = .darkGray
    genreLabel.font = UIFont.systemFont(ofSize: 12)
    genreLabel.textAlignment = .center
    genreLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(genreLabel)
    
    NSLayoutConstraint.activate([
      genreLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
      genreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      genreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      genreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
    ])
  }
  
  func configure(with genre: String) {
    genreLabel.text = genre
  }
}
