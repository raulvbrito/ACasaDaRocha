//
//  GroupGalleryCollectionViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 23/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit

class GroupGalleryCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet var shadowView: UIView!
	@IBOutlet var galleryImageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.contentView.autoresizingMask.insert(.flexibleHeight)
		self.contentView.autoresizingMask.insert(.flexibleWidth)
    	self.contentView.translatesAutoresizingMaskIntoConstraints = true
	}
	
}
