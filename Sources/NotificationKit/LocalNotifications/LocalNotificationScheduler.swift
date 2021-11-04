//
//  LocalNotificationScheduler.swift
//  iOSerler
//
//  Copyright © 2021 Nursultan Askarbekuly. All rights reserved.
//

/*
 - Why do we need notifications?
 - Don’t think of notifications as just a hook into your app, they should be a self contained packet of information that allows you to complete a specific task
 */

import UIKit

public struct LocalNotificationScheduler {
    
    let scheduleConfig: LocalNotificationConfiguration
    
    private let identifierArrayKey = "notificationIdentifiers"
    internal let notificationCenter = UNUserNotificationCenter.current()
    
    public func scheduleNotifications() {
        
        cancelAllNotifications()

        /// TODO: Consider adding notification actions
        
        let daysAfterLastLaunchOnWhichToSend: [Double] = scheduleConfig.daysAfterLastLaunchOnWhichToSend
        
        let triggers = generateTriggers(daysAfterLastLaunchOnWhichToSend)
        let contents = generateContents(daysAfterLastLaunchOnWhichToSend.count)
        
        for i in 0..<triggers.count {
            
            let trigger = triggers[i]
            let content = contents[i]
            
            createNotificationRequest(with: content, trigger: trigger)
        }
    }
    
    func createNotificationRequest(with content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        
        /// Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        /// Schedule the request with the system.
        notificationCenter.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            storeRequestIdentifier(uuidString)
        }
    }
    
    func generateContents(_ count: Int) -> [UNMutableNotificationContent] {
        
        var contentArray = [UNMutableNotificationContent]()
        

        
        let titles = scheduleConfig.notificationTitles
        let bodies = scheduleConfig.notificationBodies
        let attachmentNames = scheduleConfig.attachmentNames
        (0..<count).forEach { (_) in
            // Configure the notification content
            let content = UNMutableNotificationContent()
            content.title = titles.randomElement() ?? ""
            content.body = bodies.randomElement() ?? ""
            content.sound = UNNotificationSound.default
            
            if let attachmentName = attachmentNames.randomElement(),
               let url = Bundle.main.url(forResource: attachmentName, withExtension: nil),
               let attachment = try? UNNotificationAttachment(identifier: "image", url: url, options: nil) {
                content.attachments = [attachment]
            }
            
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
