//
//  NotificationScheduler.swift
//  iOSerler
//
//  Copyright © 2021 Nursultan Askarbekuly. All rights reserved.
//

/*
 - Why do we need notifications?
 - Don’t think of notifications as just a hook into your app, they should be a self contained packet of information that allows you to complete a specific task
 */

import UIKit

enum ContentVariationExperiment {
    case Constant
    case Situational
}

enum TriggerVariationExperiment {
    case ConstantTime
    case Distributed
}

struct NotificationScheduler {
    
    let notificationTitles: [String]
    let notificationBodies: [String]
    
    private let identifierArrayKey = "notificationIdentifiers"
    internal let notificationCenter = UNUserNotificationCenter.current()
    
    func scheduleNotifications() {
        
        cancelAllNotifications()
//        configureActionsForStartingLesson()
        
        let daysCountArray: [Double] = [
            /// FIXME: test, so comment the line below for production
//            0.0001,
            /// 3x daily
            1,2,3,
            /// 2x bidaily
            5,7,
            /// 4x once in Three days
            10,13,16,19,
            /// 3x weekly
            26,34,41,
            /// 2x biweekly
            55,69,
            /// 12x monthly
            99,129,159,189,219,249,279,309,339,369,399,429
        ]
        
        let triggers = generateTriggers(daysCountArray)
        let contents = generateContents(daysCountArray.count)
        
        for i in 0..<triggers.count {
            
            let trigger = triggers[i]
            let content = contents[i]
            
            createNotificationRequest(with: content, trigger: trigger)
        }
    }
    
    func createNotificationRequest(with content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            storeRequestIdentifier(uuidString)
        }
    }
    
    func generateContents(_ count: Int) -> [UNMutableNotificationContent] {
        
        var contentArray = [UNMutableNotificationContent]()
        
//        guard let url = Bundle.main.url(forResource: "arabic alphabet", withExtension: "png"),
//              let attachment = try? UNNotificationAttachment(identifier: "image", url: url, options: nil) else {
//
//            print("Failed to initialize attachment")
//            return []
//        }
        
        let titles = notificationTitles
        let bodies = notificationBodies
        
        (0..<count).forEach { (_) in
            // Configure the notification content
            let content = UNMutableNotificationContent()
            content.title = titles.randomElement() ?? ""
            content.body = bodies.randomElement() ?? ""
            content.sound = UNNotificationSound.default
//            content.attachments = [attachment]
//            content.categoryIdentifier = CategoryIdentifiers.startLesson.rawValue
            contentArray.append(content)
        }
        
        return contentArray
    }
    
    func generateTriggers(_ dayCountArray: [Double]) -> [UNNotificationTrigger] {
        
        var triggers: [UNNotificationTrigger] = []
        
        let minute: TimeInterval = 60.0
        let hour:TimeInterval = 60.0 * minute
        let day:TimeInterval = 24 * hour
        
        for dayCount in dayCountArray {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval:dayCount*day, repeats: false)
            triggers.append(trigger)
        }
        
        return triggers
        
    }
    
    func storeRequestIdentifier(_ identifier: String) {
        
        if var identifierArray = UserDefaults.standard.array(forKey: identifierArrayKey) as? [String] {
            identifierArray.append(identifier)
            UserDefaults.standard.setValue(identifierArray, forKey: identifierArrayKey)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.setValue([identifier], forKey: identifierArrayKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
    }
    
}

//
//  NotificationActions.swift
//  Quranize
//
//  Created by Daniya on 20/03/2021.
//  Copyright © 2021 Nursultan Askarbekuly. All rights reserved.
//

//import UserNotifications
//
//
//enum NotificationAction: String {
//    case dismiss
//    case startPrayer
//}
//
//enum CategoryIdentifiers: String {
//    case startLesson
//}
//
//extension NotificationScheduler {
//    
//    func configureActionsForStartingLesson() {
//
//        //define the dismiss and reminder actions
//        let dismiss = UNNotificationAction(identifier: NotificationAction.dismiss.rawValue,
//                                           title: NotificationAction.dismiss.rawValue.localized(),
//                                                         options: [.destructive])
//
//        let startLearning = UNNotificationAction(identifier: NotificationAction.startPrayer.rawValue,
//                                                 title: NotificationAction.startPrayer.rawValue.localized(), options: [.foreground])
//
//        //associate action with a category
//        let startLessonCategory = UNNotificationCategory(identifier: CategoryIdentifiers.startLesson.rawValue,
//                                                             actions: [startLearning,dismiss],
//                                                             intentIdentifiers: [],
//                                                             options: [.customDismissAction])
//        
//        notificationCenter.setNotificationCategories([startLessonCategory])
//    }
//    
//}
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        completionHandler([.alert, .sound])
//
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if response.notification.request.identifier == "Local Notification" {
//            print("Handling notifications with the Local Notification Identifier")
//        }
//
//        let eventName = "Responded to notification"
//
//        switch response.actionIdentifier {
//        case UNNotificationDismissActionIdentifier:
//            Analytics.shared.logEvent(eventName, properties: [
//                "action": UNNotificationDismissActionIdentifier
//            ])
//        case UNNotificationDefaultActionIdentifier:
//            Analytics.shared.logEvent(eventName, properties: [
//                "action": UNNotificationDefaultActionIdentifier
//            ])
//        case NotificationAction.dismiss.rawValue:
//            Analytics.shared.logEvent(eventName, properties: [
//                "action": NotificationAction.dismiss.rawValue
//            ])
//        case NotificationAction.startPrayer.rawValue:
//            Analytics.shared.logEvent(eventName, properties: [
//                "action": NotificationAction.startPrayer.rawValue
//            ])
//        default:
//            Analytics.shared.logEvent(eventName, properties: [
//                "action": "unknown"
//            ])
//        }
//        completionHandler()
//    }
//
//}



