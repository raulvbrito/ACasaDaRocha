//
//  GroupViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 21/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

	@IBOutlet var backgroundView: UIView!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var logoImageView: UIImageView!
	@IBOutlet var descriptionLabel: UILabel!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        backgroundView.hero.modifiers = [.duration(0.3), .timingFunction(.easeInOut), .useScaleBasedSizeChange]
        logoImageView.hero.modifiers = [.duration(0.3), .timingFunction(.easeInOut), .useScaleBasedSizeChange]
    }

}

extension GroupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 320)
    }
	
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
		
		for pageBullet in stackView.arrangedSubviews {
			UIView.animate(withDuration: 0.3) {
				pageBullet.alpha = 0.3
			}
		}
		
		UIView.animate(withDuration: 0.3) {
			self.stackView.arrangedSubviews[currentPage].alpha = 1
		}

	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 5
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupGalleryCollectionViewCell", for: indexPath) as? GroupGalleryCollectionViewCell
		
		cell?.galleryImageView.image = UIImage(named: "img_\(indexPath.row)")
		
		cell?.shadowView.layer.masksToBounds = false
		cell?.shadowView.layer.shadowColor = UIColor.black.cgColor
		cell?.shadowView.layer.shadowOpacity = 0.5
		cell?.shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
		
		cell?.shadowView.layer.shadowRadius = 12

		cell?.shadowView.layer.shadowPath = UIBezierPath(rect: cell?.shadowView.bounds ?? CGRect(x: cell?.shadowView.frame.origin.x ?? 0, y: cell?.shadowView.frame.origin.y ?? 0, width: cell?.shadowView.frame.width ?? 0, height: cell?.shadowView.frame.height ?? 0)).cgPath
		cell?.shadowView.layer.shouldRasterize = true
		cell?.shadowView.layer.rasterizationScale = 1
		
        return cell!
    }
}
