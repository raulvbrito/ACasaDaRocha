//
//  IntroTableViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 05/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit
import Hero

class IntroTableViewCell: UITableViewCell {

	@IBOutlet var logoViews: [UIView]!
	@IBOutlet var fadeLabels: [UILabel]!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		for logoView in self.logoViews {
			logoView.hero.modifiers = [.duration(0.5), .timingFunction(.easeInOut), .useScaleBasedSizeChange]
		}
		
		for label in self.fadeLabels {
			UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
				label.alpha = 1
			}, completion: nil)
		}
    }

}
