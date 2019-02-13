//
//  BaseViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 14/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
			// print(familyName, fontNames)
        })
		
		// Custom fonts
		// Proxima Nova ["ProximaNova-Extrabld", "ProximaNova-Light", "ProximaNova-Black", "ProximaNova-Semibold", "ProximaNova-RegularIt", "ProximaNova-BoldIt", "ProximaNova-Bold", "ProximaNova-Thin", "ProximaNova-SemiboldIt", "ProximaNova-Regular", "ProximaNova-LightIt"]
		
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
		self.navigationController?.navigationBar.tintColor = UIColor.white
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProximaNova-Semibold", size: 18)!]
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationController?.view.backgroundColor = .black
		
		self.tabBarController?.tabBar.layer.borderWidth = 0.50
		self.tabBarController?.tabBar.layer.borderColor = UIColor.clear.cgColor
		self.tabBarController?.tabBar.clipsToBounds = true
		
		definesPresentationContext = true
		
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
			self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProximaNova-Bold", size: 34)!]
		}
    }
}
