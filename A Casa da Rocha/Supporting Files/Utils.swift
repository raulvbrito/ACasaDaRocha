//
//  Utils.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 11/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import Foundation

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIView {
	func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
		gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.2)
		gradientLayer.locations = [0, 1]
		gradientLayer.frame = bounds

	   layer.insertSublayer(gradientLayer, at: 0)
	}
	
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}
