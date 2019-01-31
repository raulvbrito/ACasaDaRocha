//
//  Group.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 30/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import Foundation
import Tailor

struct Group: Mappable {
	
	var logo: UIImage!
    var mainColor: UIColor!
    var secondaryColor: UIColor!
	
    init(_ map: [String : Any]) {
    	logo <- map.property("logo")
        mainColor <- map.property("main_color")
        secondaryColor <- map.property("secondary_color")
    }
	
}
