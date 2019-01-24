//
//  GroupCollectionViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 17/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet var cardView: UIView!
	@IBOutlet var roundedLogoView: UIView!
	@IBOutlet var logoShadowView: UIView!
	@IBOutlet var hashtagImageView: UIImageView!
	@IBOutlet var logoImageView: UIImageView!
	@IBOutlet var logoImageViewCenterYConstraint: NSLayoutConstraint!
	@IBOutlet var ageRangeLabel: UILabel!
	@IBOutlet var eventNameLabel: UILabel!
	@IBOutlet var nextEventLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
	}
}