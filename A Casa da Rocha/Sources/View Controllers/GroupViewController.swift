//
//  GroupViewController.swift
//  A Casa da Rocha
//
//  Created by Raul Brito on 21/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import FSCalendar


private enum BottomViewState {
    case closed
    case open
}

extension BottomViewState {
    var opposite: BottomViewState {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class GroupViewController: UIViewController {

	@IBOutlet var backgroundView: UIView!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var collectionViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var logoImageView: UIImageView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var closeButtonImageView: UIImageView!
	@IBOutlet var overlayView: UIView!
	@IBOutlet var followButton: UIButton!
	@IBOutlet var bottomView: UIView!
	@IBOutlet var bottomViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var bottomViewOverlay: UIView!
	@IBOutlet var leftArrowBarView: UIView!
	@IBOutlet var rightArrowBarView: UIView!
	@IBOutlet var leftArrowBarOpenedView: UIView!
	@IBOutlet var rightArrowBarOpenedView: UIView!
	@IBOutlet var leftArrowBarViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var eventCountView: UIView!
	@IBOutlet var eventCountViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var closedEventsLabel: UILabel!
	@IBOutlet var openEventsLabel: UILabel!
	@IBOutlet var panView: UIView!
	@IBOutlet var calendarView: FSCalendar!
	@IBOutlet var calendarViewTopConstraint: NSLayoutConstraint!
	
	var transitionAnimator = UIViewPropertyAnimator()
	
	private let bottomViewOffset: CGFloat = 621
	
	private var bottomOffset: CGFloat = 100
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		backgroundView.hero.modifiers = [.duration(0.3), .timingFunction(.easeInOut), .useScaleBasedSizeChange, .arc(intensity: 1)]
		logoImageView.hero.modifiers = [.duration(0.4), .timingFunction(.easeInOut), .useScaleBasedSizeChange, .arc(intensity: 1)]

		bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		
		panView.addGestureRecognizer(panRecognizer)
		
		openEventsLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: 0))
		
		leftArrowBarView.transform = CGAffineTransform(rotationAngle: 150 * .pi/180)
		rightArrowBarView.transform = CGAffineTransform(rotationAngle: 210 * .pi/180)
		
		leftArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 150 * .pi/180)
		rightArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 210 * .pi/180)
		
		if self.view.frame.height <= 667 {
			bottomOffset = 25
			
			collectionViewTopConstraint.constant = collectionViewTopConstraint.constant - 10
			collectionViewHeightConstraint.constant = collectionViewHeightConstraint.constant - 40
			
			collectionView.reloadData()
		}
		
		calendarSetup()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		bottomViewBottomConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height - bottomOffset
		
		var originalTransform = self.collectionView.transform
		var translatedTransform = originalTransform.translatedBy(x: self.view.frame.size.width, y: 0)
		self.collectionView.transform = translatedTransform
		
		originalTransform = self.bottomView.transform
		translatedTransform = originalTransform.translatedBy(x: 0, y: self.view.frame.size.height)
		self.bottomView.transform = translatedTransform

		let timingFunction = CAMediaTimingFunction(controlPoints: 5/6, 0.2, 2/6, 0.9)

		CATransaction.begin()
		CATransaction.setAnimationTimingFunction(timingFunction)

		UIView.animate(withDuration: 0.4) {
			self.collectionView.isHidden = false
			self.bottomView.isHidden = false
			
			self.collectionView.transform = .identity
			self.bottomView.transform = .identity
		}

		CATransaction.commit()
	}
	
	func calendarSetup() {
		calendarView.scrollDirection = .horizontal
		calendarView.scope = .week
		calendarView.appearance.headerTitleFont = UIFont(name: "ProximaNova-Semibold", size: 24)!
		calendarView.appearance.titleFont = UIFont(name: "ProximaNova-Semibold", size: 14)!
		calendarView.appearance.weekdayFont = UIFont(name: "ProximaNova-Regular", size: 12)!
		calendarView.locale = Locale(identifier: "pt_BR")
		
		print(calendarView.selectedDate)
	}
	
	private var currentState: BottomViewState = .closed
	
	private var runningAnimators = [UIViewPropertyAnimator]()
	
	private var animationProgress = [CGFloat]()
	
	private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(bottomViewPanned(recognizer:)))
        return recognizer
    }()
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	fileprivate func animateTransitionIfNeeded(to state: BottomViewState, duration: TimeInterval) {
		guard runningAnimators.isEmpty else { return }
		
        transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomViewBottomConstraint.constant = 100
                self.bottomViewOverlay.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
                self.closedEventsLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 0))
                self.openEventsLabel.transform = .identity
				
                self.eventCountViewLeadingConstraint.constant = 12
                self.bottomViewOverlay.alpha = 1
                self.leftArrowBarView.alpha = 0
                self.rightArrowBarView.alpha = 0
                self.leftArrowBarOpenedView.alpha = 1
                self.rightArrowBarOpenedView.alpha = 1
                self.leftArrowBarViewTopConstraint.constant = -12
                self.leftArrowBarView.transform = CGAffineTransform(rotationAngle: 180 * .pi/180)
				self.rightArrowBarView.transform = CGAffineTransform(rotationAngle: 180 * .pi/180)
				self.leftArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 180 * .pi/180)
				self.rightArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 180 * .pi/180)
				self.calendarView.alpha = 1
				self.calendarViewTopConstraint.constant = -50
            case .closed:
				self.bottomViewBottomConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height - self.bottomOffset
                self.bottomViewOverlay.layer.cornerRadius = 0
                self.overlayView.alpha = 0
                self.closedEventsLabel.transform = .identity
                self.openEventsLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: 0, y: 0))
				
                self.eventCountViewLeadingConstraint.constant = -20
                self.bottomViewOverlay.alpha = 0
                self.leftArrowBarView.alpha = 1
                self.rightArrowBarView.alpha = 1
                self.leftArrowBarOpenedView.alpha = 0
                self.rightArrowBarOpenedView.alpha = 0
                self.leftArrowBarViewTopConstraint.constant = 12
                self.leftArrowBarView.transform = CGAffineTransform(rotationAngle: 150 * .pi/180)
				self.rightArrowBarView.transform = CGAffineTransform(rotationAngle: 210 * .pi/180)
				self.leftArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 150 * .pi/180)
				self.rightArrowBarOpenedView.transform = CGAffineTransform(rotationAngle: 210 * .pi/180)
				self.calendarView.alpha = 0
				self.calendarViewTopConstraint.constant = 30
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            switch self.currentState {
            case .open:
                self.bottomViewBottomConstraint.constant = 100
                self.eventCountViewLeadingConstraint.constant = 12
            case .closed:
				self.bottomViewBottomConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height - self.bottomOffset
                self.eventCountViewLeadingConstraint.constant = -20
            }
			
            self.runningAnimators.removeAll()
        }
		
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
			switch state {
			case .open:
				self.openEventsLabel.alpha = 0
			case .closed:
				self.closedEventsLabel.alpha = 1
			}
		})
		inTitleAnimator.scrubsLinearly = false

		let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
			switch state {
			case .open:
				self.closedEventsLabel.alpha = 0
			case .closed:
				self.openEventsLabel.alpha = 0
			}
		})
		outTitleAnimator.scrubsLinearly = false
		
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
		
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
	}
	
	@objc private func bottomViewPanned(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			animateTransitionIfNeeded(to: currentState.opposite, duration: 0.8)
			runningAnimators.forEach { $0.pauseAnimation() }
			animationProgress = runningAnimators.map { $0.fractionComplete }
		case .changed:
			let translation = recognizer.translation(in: bottomView)
			var fraction = -translation.y / self.bottomViewOffset
			
			if currentState == .open { fraction *= -1 }
			if runningAnimators[0].isReversed { fraction *= -1 }
			
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
		case .ended:
            let yVelocity = recognizer.velocity(in: bottomView).y
            let shouldClose = yVelocity > 0
			
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
			
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
			
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
		default:
			()
		}
	}

	@IBAction func close(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func follow(_ sender: UIButton) {
		followButton.setTitle(followButton.titleLabel?.text == "Seguir" ? "Seguindo" : "Seguir", for: .normal)
		
		let tintColor = followButton.tintColor
		let backgroundColor = followButton.backgroundColor
		
		followButton.tintColor = backgroundColor
		followButton.backgroundColor = tintColor
	}
	
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
		self.state = UIGestureRecognizer.State.began
    }
	
}

extension GroupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: collectionViewHeightConstraint.constant)
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
		
        cell?.setNeedsLayout()
		cell?.layoutIfNeeded()
		
		cell?.galleryImageView.image = UIImage(named: "img_\(indexPath.row)")
		
		cell?.shadowView.layer.masksToBounds = false
		cell?.shadowView.layer.shadowColor = UIColor.black.cgColor
		cell?.shadowView.layer.shadowOpacity = 0.6
		cell?.shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
		cell?.shadowView.layer.zPosition = 0
		
		cell?.shadowView.layer.shadowRadius = 10

		cell?.shadowView.layer.shadowPath = UIBezierPath(roundedRect: (cell?.shadowView.bounds)!, cornerRadius: cell?.galleryImageView.layer.cornerRadius ?? 0).cgPath
		cell?.shadowView.layer.shouldRasterize = true
		cell?.shadowView.layer.rasterizationScale = UIScreen.main.scale
		
        return cell!
    }
}
