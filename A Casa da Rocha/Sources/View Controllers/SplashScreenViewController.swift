//
//  SplashScreenViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 16/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import Hero

class SplashScreenViewController: UIViewController {

	// MARK: - Properties

	@IBOutlet var logoView: UIView!
	
	@IBOutlet var verticalLeftView: UIView!
	@IBOutlet var verticalLeftViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var verticalMiddleView: UIView!
	@IBOutlet var verticalMiddleViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var verticalRigthView: UIView!
	@IBOutlet var verticalRightViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var horizontalTopView: UIView!
	@IBOutlet var horizontalTopViewLeftConstraint: NSLayoutConstraint!
	
	@IBOutlet var horizontalMiddleTopView: UIView!
	@IBOutlet var horizontalMiddleTopViewLeftConstraint: NSLayoutConstraint!
	
	@IBOutlet var horizontalMiddleBottomView: UIView!
	@IBOutlet var horizontalMiddleBottomViewLeftConstraint: NSLayoutConstraint!
	
	@IBOutlet var horizontalBottomView: UIView!
	@IBOutlet var horizontalBottomViewLeftConstraint: NSLayoutConstraint!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	
	// MARK: - Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.logoAnimation(reverse: false)
		}
    }

	func logoAnimation(reverse: Bool) {
		let duration = 0.4
		
		if !reverse {
			UIView.animate(withDuration: duration, animations: {
				self.horizontalTopViewLeftConstraint.constant = 41
				
				self.view.layoutIfNeeded()
			}) { (Bool) in
				UIView.animate(withDuration: duration, animations: {
					self.verticalLeftViewTopConstraint.constant = 47
					
					self.view.layoutIfNeeded()
				}) { (Bool) in
					UIView.animate(withDuration: duration, animations: {
						self.verticalMiddleViewTopConstraint.constant = 24
						
						self.view.layoutIfNeeded()
					}) { (Bool) in
						UIView.animate(withDuration: duration, animations: {
							self.horizontalMiddleTopViewLeftConstraint.constant = 17
							
							self.view.layoutIfNeeded()
						}) { (Bool) in
							UIView.animate(withDuration: duration, animations: {
								self.horizontalMiddleBottomViewLeftConstraint.constant = 55
								
								self.view.layoutIfNeeded()
							}) { (Bool) in
								UIView.animate(withDuration: duration, animations: {
									self.verticalRightViewTopConstraint.constant = 59
									
									self.view.layoutIfNeeded()
								}) { (Bool) in
									UIView.animate(withDuration: duration, animations: {
										self.horizontalBottomViewLeftConstraint.constant = 41
										
										self.view.layoutIfNeeded()
									}) { (Bool) in
										self.performSegue(withIdentifier: "HomeSegue", sender: nil)
									}
								}
							}
						}
					}
				}
			}
		} else {
			verticalLeftViewTopConstraint.constant = 292
			verticalMiddleViewTopConstraint.constant = 270
			verticalRightViewTopConstraint.constant = 282
			
			horizontalTopViewLeftConstraint.constant = 147
			horizontalMiddleTopViewLeftConstraint.constant = 126
			horizontalMiddleBottomViewLeftConstraint.constant = 160
			horizontalBottomViewLeftConstraint.constant = 147
		}
	}
}
