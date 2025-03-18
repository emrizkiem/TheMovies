//
//  MovieEntity+CoreDataProperties.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//
//

import Foundation
import CoreData

extension MovieEntity {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
    return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
  }
  
  @NSManaged public var backdropPath: String?
  @NSManaged public var id: Int64
  @NSManaged public var overview: String?
  @NSManaged public var page: Int64
  @NSManaged public var posterPath: String?
  @NSManaged public var releaseDate: String?
  @NSManaged public var title: String?
  @NSManaged public var voteAverage: Double
}

extension MovieEntity : Identifiable {}
