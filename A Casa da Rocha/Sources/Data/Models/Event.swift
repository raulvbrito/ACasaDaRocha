//
//  Event.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 22/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import Foundation
import Tailor

struct Event: Mappable {
	
    var id: Int!
    var name: String!
    var description: String!
    var location: String!
    var image: String!
    var startDate: String!
    var duration: Double!
    var addedToCalendar: Bool!
	
    init(_ map: [String : Any]) {
        id <- map.property("id")
        name <- map.property("name")
        description <- map.property("description")
        location <- map.property("location")
        image <- map.resolve(keyPath: "image")
        startDate <- map.property("start_date")
        duration <- map.property("duration")
		addedToCalendar <- map.property("added")
    }
	
}
