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

final class GroupViewController: UIViewController {

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
	@IBOutlet var eventCountViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet var eventCountButton: UIButton!
	@IBOutlet var closedEventsLabel: UILabel!
	@IBOutlet var openEventsLabel: UILabel!
	@IBOutlet var panView: UIView!
	@IBOutlet var calendarView: FSCalendar!
	@IBOutlet var calendarViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var noEventsLabel: UILabel!
	
	var events = [Event]()
	
	var filteredEvents = [Event]()
	
	var config: Group!
	
	var backgroundViewHeroId: String!
	
	var logoImageViewHeroId: String!
	
	var transitionAnimator = UIViewPropertyAnimator()
	
	var showingTable = false
	
	private let bottomViewOffset: CGFloat = 621
	
	private var bottomOffset: CGFloat = 100
	
	var datesWithEvent = ["2019-01-03", "2019-01-06", "2019-01-12", "2019-01-25", "2019-01-30"]

	var datesWithMultipleEvents = ["2019-01-08", "2019-01-16", "2019-01-20", "2019-01-28", "2019-01-30"]

	var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		return formatter
	}()
	
	let timeFormatter = DateFormatter()
	
	let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		backgroundView.hero.id = backgroundViewHeroId
		logoImageView.hero.id = logoImageViewHeroId
		
		backgroundView.hero.modifiers = [.duration(0.35), .timingFunction(.easeInOut), .useScaleBasedSizeChange, .arc(intensity: 1)]
		logoImageView.hero.modifiers = [.duration(0.45), .timingFunction(.easeInOut), .useScaleBasedSizeChange, .arc(intensity: 1)]

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
		
		colorConfig()
		calendarSetup()
    }
	
    override func viewWillAppear(_ animated: Bool) {
//    	DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//			UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
//				self.backgroundView.backgroundColor = self.config.mainColor
//
//				self.view.layoutIfNeeded()
//			}, completion: nil)
//		}
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
	
	override func viewWillDisappear(_ animated: Bool) {
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
//			self.backgroundView?.backgroundColor = .black
		}, completion: nil)
	}
	
	func calendarSetup() {
		let event = [
        	"id": 0,
        	"name": "Culto da Manhã",
        	"description": "Culto da manhã na Casa da Rocha",
        	"location": "A Casa da Rocha - Independência",
        	"image": "dark_logo",
        	"start_date": "2019-01-31 11:00",
        	"duration": 5400.0,
        	"added": false
			] as [String : Any]
		
		let event1 = [
        	"id": 1,
        	"name": "Encontro de Jovens",
        	"description": "Culto dos jovens na Casa da Rocha",
        	"location": "A Casa da Rocha - Independência",
        	"image": "skup_logo_branco",
        	"start_date": "2019-02-09 19:00",
        	"duration": 7200.0,
        	"added": false
			] as [String : Any]
		
		events.append(Event.init(event))
		events.append(Event.init(event1))
		events.append(Event.init(event))
		events.append(Event.init(event1))
		events.append(Event.init(event))
		events.append(Event.init(event1))
		events.append(Event.init(event))
		events.append(Event.init(event1))
		
		calendarView.scrollDirection = .horizontal
		calendarView.scope = .week
		calendarView.appearance.headerTitleFont = UIFont(name: "ProximaNova-Semibold", size: 30)!
		calendarView.appearance.titleFont = UIFont(name: "ProximaNova-Semibold", size: 14)!
		calendarView.appearance.weekdayFont = UIFont(name: "ProximaNova-Regular", size: 12)!
		calendarView.locale = Locale(identifier: "pt_BR")
		
		calendarView.select(Date())
		
		updateEvents()
		
		calendarView.reloadData()
	}
	
	func colorConfig() {
		logoImageView.image = config.logo
	
		backgroundView.backgroundColor = config.mainColor
		collectionView.backgroundColor = config.mainColor
		calendarView.appearance.headerTitleColor = config.mainColor
		calendarView.appearance.titleTodayColor = config.mainColor
		calendarView.appearance.selectionColor = config.mainColor
		calendarView.appearance.todaySelectionColor = config.mainColor
		
		followButton.backgroundColor = config.secondaryColor
		eventCountView.backgroundColor = config.secondaryColor
		calendarView.appearance.eventDefaultColor = config.secondaryColor
		calendarView.appearance.eventSelectionColor = config.secondaryColor
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
				
				self.eventCountViewTrailingConstraint.priority = UILayoutPriority(rawValue: 999)
				self.eventCountViewLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
                self.eventCountViewTrailingConstraint.constant = 20
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
				
				self.eventCountViewTrailingConstraint.priority = UILayoutPriority(rawValue: 250)
				self.eventCountViewLeadingConstraint.priority = UILayoutPriority(rawValue: 999)
                self.eventCountViewLeadingConstraint.constant = -20
                self.eventCountViewTrailingConstraint.constant = 87
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
                self.eventCountViewTrailingConstraint.priority = UILayoutPriority(rawValue: 999)
				self.eventCountViewLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
                self.eventCountViewTrailingConstraint.constant = 20
                self.calendarViewTopConstraint.constant = -50
            case .closed:
				self.bottomViewBottomConstraint.constant = self.view.safeAreaLayoutGuide.layoutFrame.height - self.bottomOffset
                self.eventCountViewTrailingConstraint.priority = UILayoutPriority(rawValue: 250)
				self.eventCountViewLeadingConstraint.priority = UILayoutPriority(rawValue: 999)
                self.eventCountViewLeadingConstraint.constant = -20
                self.eventCountViewTrailingConstraint.constant = 87
                self.calendarViewTopConstraint.constant = 30
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
	
	func updateEvents() {
		let dateString = self.formatter.string(from: calendarView.selectedDate!)
		
		showingTable = false
		
		filteredEvents = events.filter({ $0.startDate.contains(dateString) }).map({ return $0 })
		
		eventCountButton.setTitle(filteredEvents.count.description, for: .normal)
		
		var cells = self.tableView.visibleCells as! Array<EventTableViewCell>
		
		if cells.count <= 0 && filteredEvents.count > 0 {
			tableView.reloadData()
			
			cells = self.tableView.visibleCells as! Array<EventTableViewCell>
		}
		
		for (index, cell) in cells.reversed().enumerated() {
			let originalTransform = cell.cardView.transform
			let scaledTransform = originalTransform.scaledBy(x: 0.5, y: 0.5)

			UIView.animate(withDuration: 0.25, delay: Double(index)*0.05, options: .curveEaseInOut, animations: {
				cell.cardView.alpha = 0
				cell.shadowView.alpha = 0
				cell.cardView.transform = scaledTransform
			}, completion: nil)
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
			self.tableView.reloadData()
			
			UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
				if self.filteredEvents.count <= 0 {
					self.noEventsLabel.alpha = 1
				} else {
					self.noEventsLabel.alpha = 0
				}
			}) { (Bool) in
				for (index, cell) in cells.enumerated() {
					UIView.animate(withDuration: 0.3, delay: Double(index)*0.05, options: .curveEaseInOut, animations: {
						cell.cardView.alpha = 1
						cell.cardView.transform = .identity
					}) { (Bool) in
//						UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//							cell.shadowView.alpha = 1
//						}, completion: nil)
						
						self.showingTable = true
					}
				}
			}
		})
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
	
	@IBAction func today(_ sender: Any) {
	
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
		cell?.shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
		cell?.shadowView.layer.cornerRadius = 20.0
		cell?.shadowView.layer.shadowRadius = 12.0

		cell?.shadowView.layer.shadowPath = UIBezierPath(roundedRect: (cell?.shadowView.bounds)!, cornerRadius: cell?.galleryImageView.layer.cornerRadius ?? 0).cgPath
		cell?.shadowView.layer.shouldRasterize = true
		cell?.shadowView.layer.rasterizationScale = UIScreen.main.scale
		
        return cell!
    }
}

extension GroupViewController: FSCalendarDelegate, FSCalendarDataSource {
	func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
		let dateString = self.formatter.string(from: date)
		
		let dates = events.map { (date) -> String in
			let endIndex = date.startDate.index(date.startDate.endIndex, offsetBy: -6)
			let truncated = date.startDate.substring(to: endIndex)
			return truncated
		}
		
		if dates.contains(dateString) {
			return 1
		}

		return 0
	}
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
		updateEvents()
	}
}

extension GroupViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 110
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredEvents.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell") as? EventTableViewCell
		
		self.timeFormatter.dateFormat = "HH:mm"
		
		cell?.setNeedsLayout()
		cell?.layoutIfNeeded()
		
		cell?.shadowView.alpha = 0
		cell?.shadowView.layer.masksToBounds = false
		cell?.shadowView.layer.shadowColor = UIColor.black.cgColor
		cell?.shadowView.layer.shadowOpacity = 0.6
		cell?.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
		cell?.shadowView.layer.cornerRadius = 12
		cell?.shadowView.layer.shadowRadius = 10

		cell?.shadowView.layer.shadowPath = UIBezierPath(roundedRect: (cell?.shadowView.bounds)!, cornerRadius: 0).cgPath
		cell?.shadowView.layer.shouldRasterize = true
		cell?.shadowView.layer.rasterizationScale = UIScreen.main.scale
		
		
		if !showingTable {
			cell?.cardView.alpha = 0
		}
		
		cell?.cardView.backgroundColor = config.mainColor
		cell?.titleLabel.text = self.filteredEvents[indexPath.row].name
		cell?.timeBarView.backgroundColor = config.secondaryColor
		cell?.startTimeLabel.text = "\(timeFormatter.string(from: dateFormatter.date(from: self.filteredEvents[indexPath.row].startDate) ?? Date()))"
		cell?.endTimeLabel.text = "\(timeFormatter.string(from: dateFormatter.date(from: self.filteredEvents[indexPath.row].startDate)?.addingTimeInterval(self.filteredEvents[indexPath.row].duration as TimeInterval) ?? Date()))"
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
