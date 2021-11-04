# Get user permission to send notifications
            
        /// create a configuration
        let config = PermissionConfiguration()
        
        /// initiliaze PermissionManager
        let manager = PermissionManager(notificationConfig: config, analytics: nil)
        
        /// pass your main ViewController where to display the permission dialogue at
        manager.hostController = self
        
        /// check the permission status and ask if needed
        manager.configureNotifications()


# Schedule local notifications

You need local notifications? You can add them easily:
        
        /// initialize the local notifications scheduler
        let scheduleConfig = LocalNotificationConfiguration()
        let scheduler = LocalNotificationScheduler(scheduleConfig: scheduleConfig)
        
        /// pass the closure to the notifications manager
        manager.scheduleLocalNotifications = scheduler.scheduleNotifications
        

# Example usage within a ViewController with full configuration and local notifications

        import UIKit
        import NotificationKit

        class MainController: UIViewController {
            
            private var manager: PermissionManager?
            
            override func viewDidLoad() {
                super.viewDidLoad()
                        
                /// create a full configuration
                let config = PermissionConfiguration(
                    enableLabelText: "enableNotifications".localized(),
                    enableButtonTitle: "enable".localized(),
                    dismissButtonTitle: "dismiss".localized(),
                    alertViewBackgroundColor: UIColor(rgb: 0xF4F4F4),
                    labelColor: UIColor(rgb: 0x555555),
                    permissionAlertType: .screen,
                    appOpenCount: AppHelper.shared.appOpenCount,
                    conditionWhenToAsk: { AppHelper.shared.appOpenCount % 2 == 0 }
                )
                
                /// initiliaze mananer
                self.manager = PermissionManager(notificationConfig: config, analytics: Analytics.shared)
                /// pass your main view controller where the permission dialogue will be displayed
                self.manager?.hostController = self
                
                /// initialize the local notifications scheduler
                let scheduleConfig = LocalNotificationConfiguration(
                    notificationTitles: ["notificationStandardTitle".localized()],
                    notificationBodies: ["notificationStandardBody".localized()]
                )
                
                let scheduler = LocalNotificationScheduler(scheduleConfig: scheduleConfig)
                self.manager?.scheduleLocalNotifications = scheduler.scheduleNotifications
                
                self.manager?.configureNotifications()
            }

        }


# AB test various configurations 

You can also use the functionality with the remote control package for A/B testing


## Experiment with different ways to ask for permission 

        let remoteConfigManager = RemoteConfigManager()
        
        remoteConfigManager.executeConfig = { [weak self] () in
        
            guard remoteConfigManager.didFetchSuccessfully else {
                return
            }
        
            let remoteConfigKey = RemoteConfigKey.permissionAlertType
            let remoteConfigValue = remoteConfigManager.remoteConfigValue(remoteConfigKey)

            
            print("remoteConfigKey", remoteConfigKey)
            print("remoteConfigStringValue", remoteConfigValue.rawValue)
            
            /// create a configuration
            let config = NotificationConfiguration(permissionAlertType: remoteConfigValue)
            /// initiliaze mananer
            let manager = NotificationManager(notificationConfig: config, analytics: nil)
            /// pass your main view controller where the permission dialogue will be displayed
            manager.hostController = self
            
            manager.configureNotifications()
        }
        
        RemoteConfigManager.shared.fetchRemoteConfig()
    
## Experiment with schedules 
