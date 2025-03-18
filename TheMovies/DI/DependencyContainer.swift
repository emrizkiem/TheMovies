//
//  DependencyContainer.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Swinject
import CoreData

class DependencyContainer {
  static let shared = DependencyContainer()
  let container = Container()
  
  private init() {
    registerDependencies()
  }
  
  private func registerDependencies() {
    container.register(NSManagedObjectContext.self) { _ in
      let persistentContainer = NSPersistentContainer(name: "MovieModel")
      persistentContainer.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return persistentContainer.viewContext
    }.inObjectScope(.container)
    
    container.register(NetworkService.self) { _ in
      return NetworkService()
    }.inObjectScope(.container)
    
    container.register(MovieRemoteDataSource.self) { resolver in
      let networkService = resolver.resolve(NetworkService.self)!
      return MovieRemoteDataSource(networkService: networkService)
    }
    
    container.register(MovieLocalDataSource.self) { resolver in
      let context = resolver.resolve(NSManagedObjectContext.self)!
      return MovieLocalDataSource(context: context)
    }
    
    container.register(MovieRepositoryProtocol.self) { resolver in
      let remoteDataSource = resolver.resolve(MovieRemoteDataSource.self)!
      let localDataSource = resolver.resolve(MovieLocalDataSource.self)!
      return MovieRepository(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
    }
    
    container.register(MovieUseCaseProtocol.self) { resolver in
      let repository = resolver.resolve(MovieRepositoryProtocol.self)!
      return MovieUseCase(repository: repository)
    }
    
    container.register(MovieViewModel.self) { resolver in
      let useCase = resolver.resolve(MovieUseCaseProtocol.self)!
      return MovieViewModel(useCase: useCase)
    }
    
    container.register(MovieViewController.self) { resolver in
      let viewModel = resolver.resolve(MovieViewModel.self)!
      return MovieViewController(viewModel: viewModel)
    }
    
    container.register(MovieDetailViewModel.self) { (resolver, movieId: Int) in
      let useCase = resolver.resolve(MovieUseCaseProtocol.self)!
      return MovieDetailViewModel(useCase: useCase, movieId: movieId)
    }
    
    container.register(MovieDetailViewController.self) { (resolver, movieId: Int) in
      let viewModel = resolver.resolve(MovieDetailViewModel.self, argument: movieId)!
      return MovieDetailViewController(viewModel: viewModel, movieId: movieId)
    }
  }
}
