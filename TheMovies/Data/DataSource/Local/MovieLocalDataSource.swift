//
//  MovieLocalDataSource.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift
import CoreData

protocol MovieLocalDataSourceProtocol {
  func saveMovies(_ movies: [Movie], page: Int) -> Completable
  func getMovies() -> Observable<[Movie]>
  func getMoviesForPage(page: Int) -> Observable<[Movie]>
  func clearAllMovies() -> Completable
}

final class MovieLocalDataSource: MovieLocalDataSourceProtocol {
  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func saveMovies(_ movies: [Movie], page: Int = 1) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self = self else { return Disposables.create() }
      
      self.context.perform {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "page == %d", page)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
          try self.context.execute(deleteRequest)
          
          for movie in movies {
            let entity = MovieEntity(context: self.context)
            entity.id = Int64(movie.id)
            entity.title = movie.title
            entity.overview = movie.overview
            entity.posterPath = movie.posterPath
            entity.backdropPath = movie.backdropPath
            entity.releaseDate = movie.releaseDate
            entity.voteAverage = movie.voteAverage
            entity.page = Int64(page)
          }
          
          try self.context.save()
          completable(.completed)
        } catch {
          completable(.error(error))
        }
      }
      return Disposables.create()
    }
  }
  
  func getMovies() -> Observable<[Movie]> {
    return Observable.create { [weak self] observer in
      guard let self = self else { return Disposables.create() }
      
      self.context.perform {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
          let entities = try self.context.fetch(fetchRequest)
          let movies = entities.map { $0.toMovie() }
          observer.onNext(movies)
          observer.onCompleted()
        } catch {
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func getMoviesForPage(page: Int) -> Observable<[Movie]> {
    return Observable.create { [weak self] observer in
      guard let self = self else { return Disposables.create() }
      
      self.context.perform {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "page == %d", page)
        
        do {
          let entities = try self.context.fetch(fetchRequest)
          let movies = entities.map { $0.toMovie() }
          observer.onNext(movies)
          observer.onCompleted()
        } catch {
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func clearAllMovies() -> Completable {
    return Completable.create { [weak self] completable in
      guard let self = self else { return Disposables.create() }
      
      self.context.perform {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
          try self.context.execute(deleteRequest)
          try self.context.save()
          completable(.completed)
        } catch {
          completable(.error(error))
        }
      }
      return Disposables.create()
    }
  }
}
