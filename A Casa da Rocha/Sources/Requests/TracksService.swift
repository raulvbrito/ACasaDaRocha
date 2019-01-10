//
//  TracksService.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 10/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class TracksService: BaseService {
	
    // MARK: - API Endpoints
	
    static let Tracks = "v1/shows/0eFOL5pJ1QW4sR7OMcn5GX/episodes?offset=0&limit=20"
	
    static let SpotifyClientID = "a802cee147dd4b108a4dd0238ec7c413"
	
	
    // MARK: - API URLs
	
    enum URLs {
		
        static var TracksURL = "\(spotifyBaseUrl)\(Tracks)"
		
    }
	
	
    // MARK: - API Requests
	
    static func listTracks(accessToken: String, completion: @escaping (_ error: NSError?, _ result: [Track]) -> Void){
		
        let url = "\(URLs.TracksURL)"
		
        print(url)
		
        self.instance.headersSet["Authorization"] = "Bearer \(accessToken)"
		
        print(self.instance.headersSet)
		
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.instance.headersSet).validate().responseJSON{ response in
			
            print(response)
            print(response.result)
			
            switch response.result {
            case .success(let JSON):
				
                //Error
                guard let result = JSON as? JSONDictionary else {
					completion(NSError(domain: "Não foi possível listar as faixas", code: 400, userInfo: nil), [])
                    return
                }
				
                print(result)
				
                //Success
				let tracks = result.array("items")?.compactMap(Track.init) ?? []
				
                print(tracks)
				
                completion(nil, tracks)
				
                break
				
            default:
				completion(NSError(domain: "Não foi possível listar as faixas", code: 400, userInfo: nil), [])
                break
            }
            return
        }
    }
	
}
