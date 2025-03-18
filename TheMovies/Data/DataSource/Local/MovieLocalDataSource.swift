//
//  MovieLocalDataSource.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import RxSwift
import CoreData

protocol MovieLocalDataSource {
  func saveMovies(_ movies: [Movie]) -> Completable
  func getMovies() -> Observable<[Movie]>
}

final class MovieLocalDataSourceImpl: MovieLocalDataSource {
  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func saveMovies(_ movies: [Movie]) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self = self else { return Disposables.create() }
      
      self.context.perform {
        for movie in movies {
          let entity = MovieEntity(context: self.context)
          entity.id = Int64(movie.id)
          entity.title = movie.title
          entity.overview = movie.overview
          entity.posterPath = movie.posterPath
          entity.backdropPath = movie.backdropPath
          entity.releaseDate = movie.releaseDate
          entity.voteAverage = movie.voteAverage
        }
        
        do {
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
}
