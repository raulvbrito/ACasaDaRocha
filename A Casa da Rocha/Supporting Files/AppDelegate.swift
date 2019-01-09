//
//  AppDelegate.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 05/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Spartan

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	let SpotifyClientID = "a802cee147dd4b108a4dd0238ec7c413"
	let SpotifyRedirectURL = URL(string: "a-casa-da-rocha://spotify-login-callback")!

	lazy var configuration = SPTConfiguration(
	  clientID: SpotifyClientID,
	  redirectURL: SpotifyRedirectURL
	)
	
	lazy var sessionManager: SPTSessionManager = {
	  if let tokenSwapURL = URL(string: "https://a-casa-da-rocha.herokuapp.com/api/token"),
		 let tokenRefreshURL = URL(string: "https://a-casa-da-rocha.herokuapp.com/api/refresh_token") {
		self.configuration.tokenSwapURL = tokenSwapURL
		self.configuration.tokenRefreshURL = tokenRefreshURL
		self.configuration.playURI = ""
	  }
		let manager = SPTSessionManager(configuration: self.configuration, delegate: self as? SPTSessionManagerDelegate)
	  return manager
	}()
	
	lazy var appRemote: SPTAppRemote = {
	  let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
		appRemote.delegate = self as? SPTAppRemoteDelegate
	  return appRemote
	}()
	
//	var homeViewController = HomeViewController()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//		let requestedScopes: SPTScope = [.appRemoteControl]
//        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
		
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		let params = self.appRemote.authorizationParameters(from: url)
		
		if let code = params?["code"] {
			print(code)
			
			Alamofire.request("https://a-casa-da-rocha.herokuapp.com/api/token?code=" + code, method: .post, parameters: ["code": code], encoding: JSONEncoding.default, headers: ["Authorization": "", "Content-Type": "application/json"]).validate().responseJSON { response in
					print(response)
					print(response.result)
				
					switch response.result {
					case .success(let JSON):
						
						//Error
						guard let result = JSON as? JSONDictionary else {
//							completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
							return
						}
						
						print(result)
						
						self.sessionManager.application(app, open: url, options: options)
						
						if let tabBarController = self.window?.rootViewController as? UITabBarController,
						   let navigationController = tabBarController.viewControllers?[2] as? UINavigationController,
						   let homeViewController = navigationController.visibleViewController as? HomeViewController {
							homeViewController.listTracks(result)
						}
						
						break
						
					default:
//						completion(NSError(domain: "Não foi possível obter o access_token", code: 400, userInfo: nil), [:])
						break
					}
					return
				}
		} else {
        	self.sessionManager.application(app, open: url, options: options)
		}
		
        return true
    }

	func applicationWillResignActive(_ application: UIApplication) {
		if self.appRemote.isConnected {
			self.appRemote.disconnect()
	  	}
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		if let _ = self.appRemote.connectionParameters.accessToken {
			self.appRemote.connect()
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "A_Casa_da_Rocha")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}

}

