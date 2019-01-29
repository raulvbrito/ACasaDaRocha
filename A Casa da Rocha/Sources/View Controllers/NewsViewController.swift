//
//  NewsViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 14/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit

class NewsViewController: BaseViewController {

	@IBOutlet var tableView: UITableView!
	
	var selectedCell: GroupCollectionViewCell?
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
//    override func viewWillAppear(_ animated: Bool) {
//		tableView.reloadData()
//	}
	
}


// MARK: Extensions

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsTableViewCell", for: indexPath) as? GroupsTableViewCell
		
        cell?.collectionView.tag = indexPath.item
		
        cell?.collectionView.hero.modifiers = [.cascade]
		
        cell?.collectionView.reloadData()
		
        return cell!
    }
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
	
}

extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 230)
    }
	
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
		
		let tableViewCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! GroupsTableViewCell
		
		for pageBullet in tableViewCell.stackView.arrangedSubviews {
			UIView.animate(withDuration: 0.3) {
				pageBullet.alpha = 0.3
			}
		}
		
		UIView.animate(withDuration: 0.3) {
			tableViewCell.stackView.arrangedSubviews[currentPage].alpha = 1
		}

	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionViewCell", for: indexPath) as? GroupCollectionViewCell
		
		cell?.hero.modifiers = [.fade, .scale(0.5)]
		
        switch indexPath.row {
        	case 0:
				cell?.cardView.backgroundColor = UIColor(red: 17/255, green: 26/255, blue: 40/255, alpha: 1) //UIColor(red: 21/255, green: 72/255, blue: 144/255, alpha: 1)
				cell?.roundedLogoView.backgroundColor = UIColor(red: 246/255, green: 36/255, blue: 0/255, alpha: 1)
				cell?.ageRangeLabel.text = "12 - 17"
				cell?.nextEventLabel.textColor = UIColor(red: 255/255, green: 102/255, blue: 0/255, alpha: 1)
				cell?.eventNameLabel.text = "Encontro da Galera"
				cell?.logoImageView.image = UIImage(named: "galera_logo_branco")
				cell?.logoImageViewCenterYConstraint.constant = 0
				cell?.hashtagImageView.isHidden = false
			case 1:
				cell?.cardView.backgroundColor = UIColor(red: 0/255, green: 154/255, blue: 178/255, alpha: 1)
				cell?.roundedLogoView.backgroundColor = UIColor(red: 24/255, green: 0/255, blue: 38/255, alpha: 1)
				cell?.ageRangeLabel.text = "18 - 25"
				cell?.nextEventLabel.textColor = UIColor(red: 24/255, green: 0/255, blue: 38/255, alpha: 1)
				cell?.eventNameLabel.text = "Encontro de Jovens"
				cell?.logoImageView.image = UIImage(named: "skup_logo_branco")
			case 2:
				cell?.cardView.backgroundColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
				cell?.roundedLogoView.backgroundColor = UIColor(red: 17/255, green: 11/255, blue: 9/255, alpha: 1)
				cell?.ageRangeLabel.text = "26 - 34"
				cell?.nextEventLabel.textColor = UIColor(red: 79/255, green: 189/255, blue: 187/255, alpha: 1)
				cell?.eventNameLabel.text = "Reunião do Trilha"
				cell?.logoImageView.image = UIImage(named: "trilha_logo_branco")
			default:
				break
		}
		
		let attrString = NSMutableAttributedString(string: cell?.eventNameLabel.text ?? "")
		let style = NSMutableParagraphStyle()
		style.lineSpacing = 0
		style.minimumLineHeight = 0
		style.lineHeightMultiple = 0.9
		attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: cell?.eventNameLabel.text?.characters.count ?? 0))
		cell?.eventNameLabel.attributedText = attrString
		
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
//			UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//				print("returned")
//
//				cell?.roundedLogoViewBottomConstraint.constant = -40
//				cell?.roundedLogoViewTrailingConstraint.constant = -10
//
//				self.view.layoutIfNeeded()
//			}, completion: nil)
//		}
		
        return cell!
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "GroupSegue", sender: nil)
		
//		selectedCell = collectionView.cellForItem(at: indexPath) as? GroupCollectionViewCell
		
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//			print("gone up")
//
//			self.selectedCell?.roundedLogoViewBottomConstraint.constant = 10
//			self.selectedCell?.roundedLogoViewTrailingConstraint.constant = 10
//
//			self.view.layoutIfNeeded()
//		}
	}
}
