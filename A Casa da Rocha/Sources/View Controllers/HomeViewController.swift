//
//  ViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 05/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import Spartan

class HomeViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
	
	// MARK: - Properties
	
	@IBOutlet var tableView: UITableView!
	
	public static var authorizationToken: String?
	
	public static var loggingEnabled: Bool = true
	
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
	  let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
	  return manager
	}()
	
	lazy var appRemote: SPTAppRemote = {
	  let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
	  appRemote.delegate = self
	  return appRemote
	}()
	
	var tracks: [Track] = []
	
	
	// MARK: - Methods

	override func viewDidLoad() {
		super.viewDidLoad()
		
		Spartan.loggingEnabled = true
		
		let requestedScopes: SPTScope = [.appRemoteControl]
		
		self.sessionManager.initiateSession(with: requestedScopes, options: .default)
		
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationController?.view.backgroundColor = .white
		
		definesPresentationContext = true
		
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
		}
	}
	
	func listTracks(_ result: JSONDictionary) {
		Spartan.authorizationToken = result["access_token"] as? String
		
		self.appRemote.connectionParameters.accessToken = result["access_token"] as? String
		self.appRemote.connect()
		
//		self.configuration.playURI = "spotify:episode:1A6HDauzzKuTOZQQlNHQoS"
	
		let requestedScopes: SPTScope = [.appRemoteControl]
		
		_ = Spartan.getMe(success: { (user) in
			print(user.country)
			print(user.email)
		}, failure: { (error) in
			if error.errorType == .unauthorized {
				self.sessionManager.initiateSession(with: requestedScopes, options: .default)
			}
		})
	
		print(self.appRemote.connectionParameters.accessToken)
		
		TracksService.listTracks(accessToken: self.appRemote.connectionParameters.accessToken ?? "", completion: { error, tracks in
            //Error
            if error != nil {
				print(error as Any)
            } else {
				print(tracks)
				print(self.tableView)
				
				self.tracks = tracks
				self.tableView.reloadData()
			}
        })
    }
	
	
    // MARK: - Spotify
	
	func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
		print("success", session)
		
		Spartan.authorizationToken = session.accessToken
		
		_ = Spartan.getMe(success: { (user) in
			print(user)
		}, failure: { (error) in
			print(error)
		})

		self.appRemote.connectionParameters.accessToken = session.accessToken
		self.appRemote.connect()
	}
	func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
		print("fail spotify", error)
		print("fail spotify", error.localizedDescription)
	}
	func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
		print("renewed", session)
	}
	
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("connected")

		self.appRemote.playerAPI?.delegate = self
		self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
			if let error = error {
		  		debugPrint(error.localizedDescription)
			}
		})
	}
	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("disconnected")
	}
	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("failed", error)
		print("failed", error?.localizedDescription)
	}
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		print("player state changed")
		debugPrint("Track name: %@", playerState.track.name)
		debugPrint("Track contextURI: %@", playerState.contextURI)
		debugPrint("Track album uri: %@", playerState.track.album.uri)
		debugPrint("Track album name: %@", playerState.track.album.name)
		debugPrint("Track artist uri: %@", playerState.track.artist.uri)
		debugPrint("Track artist name: %@", playerState.track.artist.name)
		debugPrint("Track podcast: %@", playerState.track.isPodcast)
		debugPrint("Track uri: %@", playerState.track.uri)
	}

}

// MARK: - Extensions

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 230
		} else if indexPath.row == 1 {
			return 60
		} else {
			return 60
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tracks.count + 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "IntroTableViewCell")
		
		switch indexPath.row {
			case 0:
				cell = cell as? IntroTableViewCell
			case 1:
				cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell") as? SectionTitleTableViewCell
			default:
				cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell") as? SectionTitleTableViewCell
		}
		
		cell?.selectionStyle = .none
		cell?.selectedBackgroundView = UIView()
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
