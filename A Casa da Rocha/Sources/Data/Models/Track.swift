//
//  Track.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 08/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import Foundation
import Tailor

struct Track: Mappable {
	
    var id: Int!
    var name: String!
    var description: String!
    var audioPreview: String!
    var uri: String!
    var href: String!
    var imageUrl: String!
    var releaseDate: String!
    var type: String!
    var duration: Int!
	
    init(_ map: [String : Any]) {
        id <- map.property("id")
        name <- map.property("name")
        description <- map.property("description")
        audioPreview <- map.property("audio_preview_url")
        uri <- map.property("uri")
        href <- map.property("href")
        imageUrl <- map.resolve(keyPath: "images.0.url")
        releaseDate <- map.property("release_date")
        type <- map.property("type")
        duration <- map.property("duration_ms")
    }
}
