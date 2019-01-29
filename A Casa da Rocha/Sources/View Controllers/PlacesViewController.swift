//
//  PlacesViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 14/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacesViewController: BaseViewController {


	// MARK: - Properties

	private let placeMarkerView = Bundle.main.loadNibNamed("PlaceMarkerView", owner: nil, options: nil)?.first as! PlaceMarkerView
	
	let positions = [
		CLLocationCoordinate2D(latitude: -23.5688841, longitude: -46.6145877),
		CLLocationCoordinate2D(latitude: -23.5456456, longitude: -46.5620665),
		CLLocationCoordinate2D(latitude: -23.4672635, longitude: -46.5201513)
	]
	
	var placeMarkers = [GMSMarker()]
	
	
	// MARK: - Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
    @objc func navigate(_ sender: UIButton) {
		let selection = UISelectionFeedbackGenerator()
		
		selection.selectionChanged()
		
    	if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
			let locationURL: String = "waze://?ll=\(positions[sender.tag].latitude),\(positions[sender.tag].longitude)&navigate=yes"
			UIApplication.shared.open(URL(string: locationURL)!, options: [:], completionHandler: nil)
		} else if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
			let locationURL: String = "comgooglemaps://?saddr=&daddr=\(positions[sender.tag].latitude),\(positions[sender.tag].longitude)&directionsmode=driving"
			UIApplication.shared.open(URL(string: locationURL)!, options: [:], completionHandler: nil)
        } else {
            print("Can't use Waze or Google Maps")
        }
	}
}


// MARK: - Extensions

extension PlacesViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 190
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableViewCell") as? PlaceTableViewCell
		
		cell?.selectionStyle = .none
		cell?.selectedBackgroundView = UIView()
		
		let placeMarker = GMSMarker()
		
		let copyPlaceMarkerView = placeMarkerView.copyView()
		
		let position = positions[indexPath.row]
		
		switch indexPath.row {
			case 0:
				cell?.titleLabel.text = "Unidade Independência"
				cell?.addressLabel.text = "Rua da Independência, 850 - São Paulo"
				cell?.mapView.animate(to: GMSCameraPosition(target: position, zoom: 16, bearing: 0, viewingAngle: 90))
				
				placeMarkers.append(placeMarker)
				placeMarkers[indexPath.row].position = position
			case 1:
				cell?.titleLabel.text = "Unidade Tatuapé"
				cell?.addressLabel.text = "Rua Emílio Mallet, 1424 - São Paulo"
				cell?.mapView.animate(to: GMSCameraPosition(target: position, zoom: 16, bearing: 0, viewingAngle: 90))
			
				placeMarkers.append(placeMarker)
				placeMarkers[indexPath.row].position = position
			default:
				cell?.titleLabel.text = "Unidade Guarulhos"
				cell?.addressLabel.text = "Avenida Papa Pio XII, 195 - Guarulhos"
				cell?.mapView.animate(to: GMSCameraPosition(target: position, zoom: 16, bearing: 10, viewingAngle: 90))
			
				placeMarkers.append(placeMarker)
				placeMarkers[indexPath.row].position = position
		}
		
		let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		cell?.mapView.padding = padding
		
		let navigationIcon = UIImage(named: "navigation_icon");
		let tintedImage = navigationIcon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		cell?.navigationButton.setImage(tintedImage, for: .normal)
		
		cell?.navigationButton.tag = indexPath.row
		cell?.navigationButton.addTarget(self, action: #selector(navigate(_:)), for: .touchUpInside)
		
		cell?.mapView.isUserInteractionEnabled = false
		
		copyPlaceMarkerView.viewWithTag(1)?.clipsToBounds = true
		copyPlaceMarkerView.viewWithTag(1)?.layer.cornerRadius = 25
		
		placeMarkers[indexPath.row].iconView = copyPlaceMarkerView
		placeMarkers[indexPath.row].map = cell?.mapView
		placeMarkers[indexPath.row].appearAnimation = GMSMarkerAnimation.pop
		
		do {
			if let styleURL = Bundle.main.url(forResource: "dark", withExtension: "json") {
				cell?.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find dark.json")
            }
		} catch {
			print("Map style not applied")
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
