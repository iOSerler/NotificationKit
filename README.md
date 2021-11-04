# NotificationKit

This package provides you with several ways to ask for user's permission to send notifications.

It takes a few lines of code to that you can add to your main view controller:
            
        /// create a configuration
        let config = NotificationConfiguration()
        
        /// initiliaze mananer
        let manager = NotificationManager(notificationConfig: config, analytics: nil)
        
        /// pass your main view controller where the permission dialogue will be displayed
        manager.hostController = self
        
        manager.configureNotifications()
        
        
You need local notifications? You can use it easily:

        /// create a configuration
        let config = NotificationConfiguration()
        
        /// initiliaze mananer
        let manager = NotificationManager(notificationConfig: config, analytics: nil)
        
        /// pass your main view controller where the permission dialogue will be displayed
        manager.hostController = self
        
        /// initialize the local notifications scheduler
        let scheduleConfig = ScheduleConfiguration()
        let scheduler = NotificationScheduler(scheduleConfig: scheduleConfig)
        
        /// pass the closure to the notifications manager
        manager.scheduleLocalNotifications = scheduler.scheduleNotifications()
        
        manager.configureNotifications()

        
You can also use it with the remote control package for A/B testing

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
    
Enjoy!
