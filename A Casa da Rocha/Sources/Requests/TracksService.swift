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
	
    static func spotifyAuthentication(code: String, completion: @escaping (_ error: NSError?, _ result: JSONDictionary) -> Void){
		
        Alamofire.request("https://a-casa-da-rocha.herokuapp.com/api/token?code=" + code, method: .post, parameters: ["code": code], encoding: JSONEncoding.default, headers: ["Authorization": "", "Content-Type": "application/json"]).validate().responseJSON { response in
				print(response)
				print(response.result)
		
				switch response.result {
				case .success(let JSON):
					
					//Error
					guard let result = JSON as? JSONDictionary else {
						completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
						return
					}
					
					print(result)
					
					completion(nil, result)
					
					break
					
				default:
					completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
					break
				}
				return
		}
    }
	
    static func spotifyRefreshToken(completion: @escaping (_ error: NSError?, _ result: JSONDictionary) -> Void){
    	let userDefaults = UserDefaults.standard
		let spotifyRefreshToken = userDefaults.string(forKey: "SpotifyRefreshToken")
		
		Alamofire.request("https://a-casa-da-rocha.herokuapp.com/api/refresh_token", method: .post, parameters: ["refresh_token": spotifyRefreshToken ?? ""], encoding: URLEncoding.default, headers: ["Content-Type": "application/x-www-form-urlencoded"]).validate().responseJSON { response in
				print(response)
		
				switch response.result {
				case .success(let JSON):
					
					//Error
					guard let result = JSON as? JSONDictionary else {
						completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
						return
					}
					
					print(result)
					
					completion(nil, result)
					
					break
					
				default:
					completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
					break
				}
				return
		}
    }
	
    static func listTracks(accessToken: String, completion: @escaping (_ error: NSError?, _ result: [Track]) -> Void){
		
        let url = "\(URLs.TracksURL)"
		
        self.instance.headersSet["Authorization"] = "Bearer \(accessToken)"
		
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.instance.headersSet).validate().responseJSON{ response in
			
			print(response.request)
//            print(response)
//            print(response.result)
			
            switch response.result {
            case .success(let JSON):
				
                //Error
                guard let result = JSON as? JSONDictionary else {
					completion(NSError(domain: "Não foi possível listar as faixas", code: 400, userInfo: nil), [])
                    return
                }
				
                //Success
				let tracks = result.array("items")?.compactMap(Track.init) ?? []
				
                completion(nil, tracks)
				
                break
				
            default:
            	print(response)
            	print(response.result)
            	print(response.response)
            	print(response.response?.statusCode)
				
				completion(NSError(domain: "Não foi possível listar as faixas", code: response.response?.statusCode ?? 400, userInfo: nil), [])
                break
            }
            return
        }
    }
	
}
