//
//  ViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 05/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import MediaPlayer

class HomeViewController: BaseViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
	
	// MARK: - Properties
	
	@IBOutlet var tableView: UITableView!
	
	public static var authorizationToken: String?
	
	public static var loggingEnabled: Bool = true
	
	let SpotifyClientID = "a802cee147dd4b108a4dd0238ec7c413"
	let SpotifyRedirectURL = URL(string: "a-casa-da-rocha://spotify-login-callback")!
	
	let requestedScopes: SPTScope = [.appRemoteControl]
	
	lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
		
		// Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""

        configuration.tokenSwapURL = URL(string: "https://a-casa-da-rocha.herokuapp.com/api/token")
        configuration.tokenRefreshURL = URL(string: "https://a-casa-da-rocha.herokuapp.com/api/refresh_token")
        return configuration
    }()
	
	lazy var sessionManager: SPTSessionManager = {
	  let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
	  return manager
	}()
	
	lazy var appRemote: SPTAppRemote = {
	  let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
	  appRemote.delegate = self
	  return appRemote
	}()
	
	var tracks: [Track] = []
	var nowPlayingIndex: Int = -1
	
	weak var trackProgressTimer: Timer?
	
	
	// MARK: - Methods

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let userDefaults = UserDefaults.standard
		
		if let spotifyAccessToken = userDefaults.string(forKey: "SpotifyAccessToken"),
		   let spotifyRefreshToken = userDefaults.string(forKey: "SpotifyRefreshToken") {
			let spotifyAuth: JSONDictionary = [
				"access_token": spotifyAccessToken,
				"refresh_token": spotifyRefreshToken
			]

//			self.sessionManager.initiateSession(with: self.requestedScopes, options: .default)
			listTracks(spotifyAuth)
		} else if let spotifyCode = userDefaults.string(forKey: "SpotifyCode") {
			print("Stored Spotify Code: " + spotifyCode)
		
			spotifyAuthentication(code: spotifyCode)
		} else {
			self.sessionManager.initiateSession(with: self.requestedScopes, options: .default)
		}
		
//		sessionManager.renewSession()
		
		tableView.estimatedRowHeight = 200
		tableView.rowHeight = UITableView.automaticDimension
	}
	
	func spotifyAuthentication(code: String?) {
		TracksService.spotifyAuthentication(code: code ?? "", completion: { error, result in
			if error != nil {
				print(error as Any)
				
				self.sessionManager.initiateSession(with: self.requestedScopes, options: .default)
			} else {
				print(result)
				
				let userDefaults = UserDefaults.standard
		
				do {
					userDefaults.set(code, forKey: "SpotifyCode")
					userDefaults.set(result["access_token"], forKey: "SpotifyAccessToken")
					userDefaults.set(result["refresh_token"], forKey: "SpotifyRefreshToken")
				} catch {
					print("Not able to save SpotifyAuth")
				}
				
				userDefaults.synchronize()
				
				self.listTracks(result)
			}
		})
	}
	
	func listTracks(_ result: JSONDictionary) {
		self.appRemote.connectionParameters.accessToken = result["access_token"] as? String
		
		TracksService.listTracks(accessToken: self.appRemote.connectionParameters.accessToken ?? "", completion: { error, tracks in
            //Error
            if error != nil {
				print(error as Any)
				
				if error?.code == 401 {
					TracksService.spotifyRefreshToken(completion: { error, result in
						if error != nil {
							print(error as Any)
							
							self.sessionManager.initiateSession(with: self.requestedScopes, options: .default)
						} else {
							let userDefaults = UserDefaults.standard
		
							do {
								userDefaults.set(result["access_token"], forKey: "SpotifyAccessToken")
							} catch {
								print("Not able to save SpotifyAccessToken")
							}
							
							userDefaults.synchronize()
							
							self.listTracks(result)
						}
					})
				}
            } else {
//				print(tracks)

				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					if !self.appRemote.isConnected {
						self.appRemote.connect()
					}
				}
				
				self.tracks = tracks
				self.tableView.reloadData()
			}
        })
    }
	
	
    // MARK: - Spotify
	
	func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
		print("success", session)
		
		let userDefaults = UserDefaults.standard
		
		userDefaults.synchronize()

		self.appRemote.connectionParameters.accessToken = session.accessToken
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			if !self.appRemote.isConnected {
				self.appRemote.connect()
			}
		}
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
			
			self.appRemote.playerAPI?.pause(nil)
		})
	}
	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("disconnected", error)
	}
	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("failed", error)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			if !self.appRemote.isConnected {
				self.sessionManager.initiateSession(with: self.requestedScopes, options: .default)
			}
		}
	}
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		print("player state changed")
		
		if nowPlayingIndex > -1 {
			tracks[nowPlayingIndex].nowPlaying = !playerState.isPaused
			tracks[nowPlayingIndex].progress = playerState.playbackPosition
			
			tableView.reloadData()
		}
		
//		debugPrint("Track name: %@", playerState.track.name)
//		debugPrint("Track contextURI: %@", playerState.contextURI)
//		debugPrint("Track album uri: %@", playerState.track.album.uri)
//		debugPrint("Track album name: %@", playerState.track.album.name)
//		debugPrint("Track artist uri: %@", playerState.track.artist.uri)
//		debugPrint("Track artist name: %@", playerState.track.artist.name)
//		debugPrint("Track podcast: %@", playerState.track.isPodcast)
//		debugPrint("Track uri: %@", playerState.track.uri)
	}
	
	@objc func trackProgress() {
		tracks[nowPlayingIndex].progress += 1000
		
		tableView.reloadData()
	}
	
	@objc func playPauseToggle(_ sender: UIButton) {
		trackProgressTimer?.invalidate()
		
		if appRemote.isConnected {
			let selection = UISelectionFeedbackGenerator()
		
			selection.selectionChanged()
		
			if nowPlayingIndex > -1 && nowPlayingIndex != sender.tag {
				tracks[nowPlayingIndex].nowPlaying = false
			}
			
			nowPlayingIndex = sender.tag
			
			tracks[nowPlayingIndex].nowPlaying = !tracks[nowPlayingIndex].nowPlaying
			
			if tracks[nowPlayingIndex].nowPlaying {
				self.configuration.playURI = tracks[nowPlayingIndex].uri
				
				self.appRemote.playerAPI?.play(tracks[nowPlayingIndex].uri, callback: { (response, error) in
					self.trackProgressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.trackProgress), userInfo: nil, repeats: true)
				})
			} else {
				self.appRemote.playerAPI?.pause({ (response, error) in
				})
			}
			
			tableView.reloadData()
	 	} else {
			self.appRemote.connect()
		}
	}
}

// MARK: - Extensions

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 200
		} else if indexPath.row == 1 {
			return 45
		} else {
			return 180
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tracks.count + 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "IntroTableViewCell") as? IntroTableViewCell
				cell?.selectionStyle = .none
				cell?.selectedBackgroundView = UIView()
				
				return cell!
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell") as? SectionTitleTableViewCell
			
				cell?.selectionStyle = .none
				cell?.selectedBackgroundView = UIView()
				
				return cell!
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell") as? TrackTableViewCell
				cell?.setup(track: tracks[indexPath.row - 2])
				cell?.playPauseButton.tag = indexPath.row - 2
				cell?.playPauseButton.addTarget(self, action: #selector(playPauseToggle(_:)), for: .touchUpInside)
				cell?.trackProgressView.setProgress(Float(Double(tracks[indexPath.row - 2].progress)/Double(tracks[indexPath.row - 2].duration)), animated: true)
				
				if !tracks[indexPath.row - 2].nowPlaying {
					cell?.playPauseImageView.image = UIImage(named: "play")
				} else {
					cell?.playPauseImageView.image = UIImage(named: "pause")
				}
			
				cell?.selectionStyle = .none
				cell?.selectedBackgroundView = UIView()
				
				return cell!
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
