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
		
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
		self.navigationController?.navigationBar.tintColor = UIColor.white
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationController?.view.backgroundColor = .black
		
		definesPresentationContext = true
		
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
		}
    }
}
