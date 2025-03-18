//
//  UIViewController.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import UIKit
import CoreData

extension MovieViewController {
    static func create() -> MovieViewController {
        let persistentContainer = NSPersistentContainer(name: "MovieModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        let context = persistentContainer.viewContext
        let networkService = NetworkService()
        let remoteDataSource = MovieRemoteDataSourceImpl(networkService: networkService)
        let localDataSource = MovieLocalDataSourceImpl(context: context)
        let repository = MovieRepository(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
        let useCase = GetMoviesUseCaseImpl(repository: repository)
        let viewModel = MovieViewModel(useCase: useCase)
        
        return MovieViewController(viewModel: viewModel)
    }
}
