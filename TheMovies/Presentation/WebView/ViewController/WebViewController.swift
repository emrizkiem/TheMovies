//
//  WebViewController.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 19/03/25.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
  
  private var webView: WKWebView!
  private let url: URL
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let navigationView = UIView()
  private let titleLabel = UILabel()
  private let backButton = UIButton(type: .system)
  
  init(url: URL, title: String) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
    self.title = title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupWebView()
    setupUI()
    setupConstraints()
    loadURL()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  private func setupWebView() {
    let configuration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = self
    webView.allowsBackForwardNavigationGestures = true
    webView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    
    view.addSubview(webView)
    
    navigationView.backgroundColor = UIColor(red: 0.788, green: 0.188, blue: 0.188, alpha: 1.0)
    navigationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(navigationView)
    
    titleLabel.text = self.title
    titleLabel.textColor = .white
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    navigationView.addSubview(titleLabel)
    
    let backImage = UIImage(systemName: "chevron.left")
    backButton.setImage(backImage, for: .normal)
    backButton.tintColor = .white
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    navigationView.addSubview(backButton)
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.color = .gray
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      navigationView.topAnchor.constraint(equalTo: view.topAnchor),
      navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      navigationView.heightAnchor.constraint(equalToConstant: 90),
      
      backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
      backButton.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: -12),
      backButton.widthAnchor.constraint(equalToConstant: 30),
      backButton.heightAnchor.constraint(equalToConstant: 30),
      
      titleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      
      webView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  private func loadURL() {
    let request = URLRequest(url: url)
    webView.load(request)
    activityIndicator.startAnimating()
  }
  
  @objc private func backButtonTapped() {
    if webView.canGoBack {
      webView.goBack()
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
}

extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    activityIndicator.stopAnimating()
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    activityIndicator.stopAnimating()
    showError(message: error.localizedDescription)
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    activityIndicator.stopAnimating()
    showError(message: error.localizedDescription)
  }
  
  private func showError(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}
