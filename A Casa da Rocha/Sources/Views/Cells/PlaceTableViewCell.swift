//
//  PlaceTableViewCell.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 15/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceTableViewCell: UITableViewCell {

	@IBOutlet var placeView: UIView!
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var navigationIconImageView: UIImageView!
	@IBOutlet var navigationButton: UIButton!
	
}
