//
//  TodayViewController.swift
//  Next Worship Widget
//
//  Created by Raul Brito on 21/01/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import NotificationCenter
import EventKit

class TodayViewController: UIViewController, NCWidgetProviding {
        
	@IBOutlet var collectionView: UICollectionView!
	
	var events = [Event]()
	
	var scrollCount = 0
	
	var collectionViewTimer = Timer()
	
	var selectedCalendarIndex = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        let event = [
        	"id": 0,
        	"name": "Culto da Manhã",
        	"description": "Culto da manhã na Casa da Rocha",
        	"location": "A Casa da Rocha - Independência",
        	"image": "dark_logo",
        	"start_date": "2019-01-27 11:00",
        	"duration": 5400.0,
        	"added": false
			] as [String : Any]
		
		let event1 = [
        	"id": 1,
        	"name": "Encontro de Jovens",
        	"description": "Culto dos jovens na Casa da Rocha",
        	"location": "A Casa da Rocha - Independência",
        	"image": "skup_logo_branco",
        	"start_date": "2019-01-26 19:00",
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
		
        startTimer()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
	
	@objc func scrollToNextCell(){
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)

        let contentOffset = collectionView.contentOffset
		
        scrollCount += 1

        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
		
        print(scrollCount)
		
        if scrollCount >= events.count {
        	scrollCount = 0
        	
			collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
		}
    }

    func startTimer() {
		collectionViewTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(TodayViewController.scrollToNextCell), userInfo: nil, repeats: true);
    }
	
    @objc func addToCalendar(_ sender: UIButton) {
		let selection = UISelectionFeedbackGenerator()
	
		selection.selectionChanged()
		
		let eventStore : EKEventStore = EKEventStore()

		eventStore.requestAccess(to: .event) { (granted, error) in
			if (granted) && (error == nil) {
				print("granted \(granted)")
				print("error \(error)")

				let event:EKEvent = EKEvent(eventStore: eventStore)

				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
				
				event.title = self.events[sender.tag].name
				event.startDate = dateFormatter.date(from: self.events[sender.tag].startDate)
				event.endDate = event.startDate.addingTimeInterval(self.events[sender.tag].duration as TimeInterval)
				event.notes = self.events[sender.tag].description
				event.calendar = eventStore.defaultCalendarForNewEvents
				event.location = self.events[sender.tag].location
				
				let reminder = EKAlarm(relativeOffset: -3600)
				event.addAlarm(reminder)
				
				do {
					try eventStore.save(event, span: .thisEvent)
					
					self.events[sender.tag].addedToCalendar = true
					
					self.selectedCalendarIndex = sender.tag
				
					self.collectionView.reloadData()
		
					self.collectionView.scrollToItem(at: IndexPath.init(row: sender.tag, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
				} catch let error as NSError {
					print("failed to save event with error : \(error)")
				}
			} else {
				print("failed to save event with error : \(error) or access not granted")
			}
		}
	}
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
		
		print(currentPage)
		
        if currentPage >= 7 {
        	collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return events.count
    }
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WidgetCollectionViewCell", for: indexPath) as? WidgetCollectionViewCell
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		
		let dateFormatter = DateFormatter()
    	dateFormatter.dateFormat = "dd 'de' MMMM"
    	dateFormatter.locale = Locale(identifier: "pt_BR")

		let timeFormatter = DateFormatter()
    	timeFormatter.dateFormat = "HH:mm"
		
		cell?.logoImageView.image = UIImage(named: events[indexPath.row].image)
		cell?.worshipNameLabel.text = events[indexPath.row].name
		cell?.dateLabel.text = dateFormatter.string(from: formatter.date(from: self.events[indexPath.row].startDate) ?? Date())
		cell?.timeLabel.text = "\(timeFormatter.string(from: formatter.date(from: self.events[indexPath.row].startDate) ?? Date())) - \(timeFormatter.string(from: formatter.date(from: self.events[indexPath.row].startDate)?.addingTimeInterval(self.events[indexPath.row].duration as TimeInterval) ?? Date()))"
		cell?.calendarButton.tag = indexPath.row
		cell?.calendarButton.addTarget(self, action: #selector(addToCalendar(_:)), for: .touchUpInside)
		
		if self.events[indexPath.row].addedToCalendar {
			cell?.calendarIconImageView.image = #imageLiteral(resourceName: "calendar_check_icon")
		} else {
			cell?.calendarIconImageView.image = #imageLiteral(resourceName: "calendar_icon")
		}
		
        switch events[indexPath.row].id {
			case 1:
				cell?.logoImageView.contentMode = .scaleAspectFit
			default:
				cell?.logoImageView.contentMode = .scaleAspectFill
		}
		
        return cell!
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
}
