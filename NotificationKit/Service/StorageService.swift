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
}

