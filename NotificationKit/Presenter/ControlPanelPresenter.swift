
import Foundation

public struct SwitchablePresenter {
    let title: String
    let isOn: Bool
}

public final class ControlPanelPresenter {
    
    var panelSections: [ControlPanelSection]
    
    private let permissionService: PermissionDialogueService
    private var analytics: GenericAnalytics?
    
    weak var view: NotificationViewInput?
    
    init(panelSections: [ControlPanelSection],
         localScheduler: LocalScheduler? = nil,
         analytics: GenericAnalytics? = nil) {
        
        self.panelSections = panelSections
        self.analytics = analytics
        
        self.permissionService = PermissionDialogueService(analytics: analytics)
        
        if let localScheduler = localScheduler {

            permissionService.scheduleLocalNotifications = LocalSchedulerService(config: localScheduler).scheduleNotifications
            
        }
    }
    
    private func toggleItemState(itemId: String) {
        
        var switchState = UserDefaults.standard.bool(forKey: itemId)
        switchState.toggle()
        UserDefaults.standard.set(switchState, forKey: itemId)
        UserDefaults.standard.synchronize()
        
        analytics?.setUserProperty(itemId, value: switchState)
        
        /// FIXME: this does not allow for flexibility.
        /// ideally consequences for actions should be determined by the client developer
        /// also depending on the controls, there can be many alternative schedules
        guard itemId == "enableNotifications" else {return}
        
        if switchState {
            permissionService.configureNotifications()
        } else {
            LocalSchedulerService.cancelAllNotifications()
        }
        
    }

}

extension ControlPanelPresenter: NotificationViewOutput {
    
    func changeState(at indexPath: IndexPath) {
        let item = panelSections[indexPath.section].items[indexPath.row]
        toggleItemState(itemId: item.id)
        view?.update()
        
    }
    
    func changeState(at section: Int) {
        let section = panelSections[section]
        toggleItemState(itemId: section.id)
        view?.update()
    }
    
    func getSectionCount() -> Int {
        return panelSections.count
    }
    
    
    func getNumberOfRows(in section: Int) -> Int {
        
        let header = panelSections[section]
        
        if UserDefaults.standard.bool(forKey: header.id) {
            return header.items.count
        } else {
            return 0
        }
        
    }
    
    func getItemControlType(for indexPath: IndexPath) -> ControlPanelType? {
        
        let controlItem = panelSections[indexPath.section].items[indexPath.row]
        
        guard let controlType = ControlPanelType(rawValue: controlItem.type) else {
            return nil
        }
        
        return controlType
    }
    
    func getSectionControlType(for section: Int) -> ControlPanelType? {
        let controlSection = panelSections[section]
        
        guard let controlType = ControlPanelType(rawValue: controlSection.type) else {
            return nil
        }
        
        return controlType
    }
    
    func getSwitchablePresenterForCell(at indexPath: IndexPath) -> SwitchablePresenter {
        let controlItem = panelSections[indexPath.section].items[indexPath.row]
        
        let isOn =  UserDefaults.standard.bool(forKey: controlItem.id)
        let presenter = SwitchablePresenter(title: controlItem.title, isOn: isOn)
        
        return presenter
    }
    
    func getSwitchablePresenterForHeader(at section: Int) -> SwitchablePresenter {
        let controlSection = panelSections[section]
        
        let isOn =  UserDefaults.standard.bool(forKey: controlSection.id)
        let presenter = SwitchablePresenter(title: controlSection.title, isOn: isOn)
        
        return presenter
    }
    
}
