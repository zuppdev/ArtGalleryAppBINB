//
//  Artwork.swift
//  ArtGallery
//
//  Domain Model for Artwork
//

import Foundation

struct Artwork: Identifiable, Equatable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let dateStart: Int?
    let dateEnd: Int?
    let mediumDisplay: String?
    let dimensions: String?
    let creditLine: String?
    let departmentTitle: String?
    let artworkTypeTitle: String?
    let imageId: String?
    let description: String?
    let placeOfOrigin: String?
    
    var imageURL: URL? {
        guard let imageId = imageId else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/843,/0/default.jpg")
    }
    
    var highResImageURL: URL? {
        guard let imageId = imageId else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/full/0/default.jpg")
    }
    
    var thumbnailURL: URL? {
        guard let imageId = imageId else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/400,/0/default.jpg")
    }
    
    var artistName: String {
        artistDisplay?.components(separatedBy: "\n").first ?? "Unknown Artist"
    }
    
    var yearDisplay: String {
        dateDisplay ?? "Unknown Date"
    }
}
