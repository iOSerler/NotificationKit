import Foundation

struct StorageService {
    
    enum StorageError: Error {
        case noFilePathError(String)
    }
    
    func getControlPanel() -> [ControlPanelSection] {
        
        var controlPanel = [ControlPanelSection]()
        let defaultControl = ControlPanelSection(id: "enableNotifications",
                                                 title: "Enable Notifications",
                                                 type: "switchable",
                                                 items: [])
        
        controlPanel.append(defaultControl)
        
        return controlPanel
    }
    
    func getPermissionDialogue() -> PermissionDialogue {
        let permissionConfiguration = PermissionDialogue(id: "standard",
                                                         enableLabelText: "Please enable notifications",
                                                         enableButtonTitle: "Enable",
                                                         dismissButtonTitle: "Dismiss",
                                                         alertViewHexColor: "#FFFFF",
                                                         labelHexColor: "#00000",
                                                         permissionAlertType: "system")
        return permissionConfiguration
    }
    
    func getLocalScheduler() -> LocalScheduler {
        let localNotificationConfiguration = LocalScheduler(id: "standard",
                                                            titles: ["Hello!"],
                                                            bodies: ["Let's use the app."],
                                                            attachmentNames: ["Thumbnail"],
                                                            schedule: [1,2,3,5,7,10,13,16,19,26,34,41,55,69,99,129,159,189,219,249,279,309,339,369,399,429])
        // The default strategy is to remind often in the beginning, then decrease the frequency.
        // start from sending daily for first three days. then switch to every other day.
        // then send a notification once in three day. then once a wee. then every other wee.
        // then keep it monthly for the rest of the year."
        return localNotificationConfiguration
    }
}

