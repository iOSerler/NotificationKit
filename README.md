# NotificationKit

A description of this package.


NotificationManager.shared.mainController = self

RemoteConfigManager.shared.executeConfig = { [weak self] () in
    
    guard RemoteConfigManager.shared.didFetchSuccessfully else {
        return
    }

    let remoteConfigKey = RemoteConfigKey.permissionAlertType
    let remoteConfigValue = RemoteConfigManager.shared.remoteConfigValue(remoteConfigKey)
    let remoteConfigStringValue = RemoteConfigManager.shared.remoteConfigStringValue(remoteConfigKey)
    
    print("remoteConfigKey", remoteConfigKey)
    print("remoteConfigStringValue", remoteConfigStringValue)
    
    NotificationManager.shared.configureNotifications()
    DispatchQueue.main.async {
        self?.mainTableView.reloadData()
    }
}
RemoteConfigManager.shared.fetchRemoteConfig()
