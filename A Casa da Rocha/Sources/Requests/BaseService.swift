//
//  BaseService.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 10/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import Foundation
import Alamofire

typealias JSONDictionary = [String : Any]
typealias JSONArray = [[String : Any]]

class BaseService {
	
    //MARK: General API Configurations
	
    class var instance: BaseService {
        struct Static {
            static let instance = BaseService()
        }
        return Static.instance
    }
	
//    static let baseUrl = "http://54.207.16.197/GtouWebApi/api/v1/"
	static let spotifyBaseUrl = "https://api.spotify.com/"
    static let soundCloudBaseUrl = "https://api.soundcloud.com/"
	
    var headersSet: HTTPHeaders = [
        "Authorization": "",
        "Content-Type": "application/json"
    ]
}
