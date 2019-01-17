//
//  SectionTitleTableViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 10/12/18.
//  Copyright © 2018 Raul Brito. All rights reserved.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
			self.titleLabel.alpha = 1
		}, completion: nil)
    }

}
