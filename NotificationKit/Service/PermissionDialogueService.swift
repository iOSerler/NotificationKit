//
//  NotificationManager.swift
//  iOSerler
//
//  Copyright © 2021 Nursultan Askarbekuly. All rights reserved.
//

import UIKit

public class PermissionDialogueService: NSObject {
    
    public var scheduleLocalNotifications: (() -> Void)?

    private let analytics: GenericAnalytics?
    
    public init(analytics: GenericAnalytics? = nil) {
        self.analytics = analytics
        super.init()
    }
    /// FIXME: is it elegant enough?
    public func getAuthorizationStatus(authorizedCompletion: @escaping () -> Void,
                                       nondeterminedCompletion: @escaping () -> Void,
                                       deniedCompletion: @escaping () -> Void) {
        
        let center  = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in

            let status = settings.authorizationStatus
            
            /// log user property
            let statusIndex = settings.authorizationStatus.rawValue
            let statusArray = ["not determined", "denied", "allowed", "provisional", "ephemeral"]
            self.analytics?.setUserProperty("Notification Status", value: statusArray[statusIndex])
            
            switch status {
            case .authorized, .ephemeral:
                authorizedCompletion()
            case .provisional, .notDetermined:
                nondeterminedCompletion()
            case .denied:
                deniedCompletion()
            @unknown default:
                break
            }
        }
            
        
    }
    
    public func configureNotifications() {
        
        getAuthorizationStatus(
            authorizedCompletion: {
                self.scheduleLocalNotifications?()
            },
            nondeterminedCompletion: {
                self.showSystemPermissionAlert()
            },
            deniedCompletion: {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        )
        
    }
    
    func showSystemPermissionAlert() {
        
        let requestingPermissionEventTitle = "Requesting Permission for Notifications"
        
        let center  = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.analytics?.logEvent(requestingPermissionEventTitle, properties: [
                    "result": "successful"
                ])
                
                self.analytics?.logEvent("NotificationPermissionGiven", properties: nil)
                self.analytics?.setUserProperty("Notification Status", value: "allowed")
                
                self.scheduleLocalNotifications?()
                
            } else if let error = error {
                print(error.localizedDescription)
                self.analytics?.logEvent(requestingPermissionEventTitle, properties: [
                    "result": "denied"
                ])
            }
        }
    }
    
}
