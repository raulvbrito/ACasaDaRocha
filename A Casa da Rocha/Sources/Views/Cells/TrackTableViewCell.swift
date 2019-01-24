//
//  TrackTableViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 10/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import SDWebImage

class TrackTableViewCell: UITableViewCell {

	@IBOutlet var playerView: UIView!
	@IBOutlet var trackCoverImageView: UIImageView!
	@IBOutlet var trackTitleLabel: UILabel!
	@IBOutlet var trackArtistLabel: UILabel!
	@IBOutlet var trackDescriptionLabel: UILabel!
	@IBOutlet var trackDurationLabel: UILabel!
	@IBOutlet var playPauseView: UIView!
	@IBOutlet var playPauseImageView: UIImageView!
	@IBOutlet var playPauseButton: UIButton!
	@IBOutlet var trackProgressView: UIProgressView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseInOut, animations: {
			self.playerView.alpha = 1
		}, completion: nil)
    }
	
	func setup(track: Track) {
		trackCoverImageView.sd_setImage(with: URL(string: track.imageUrl))
		trackTitleLabel.text = track.name
		trackArtistLabel.text = "A Casa da Rocha"
		trackDescriptionLabel.text = track.description
		trackDurationLabel.text = String((track.duration/1000)/60) + " MIN"
	}
}
