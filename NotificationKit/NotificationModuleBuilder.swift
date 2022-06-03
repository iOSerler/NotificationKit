import Foundation

public final class NotificationModuleBuilder {
    
    public let view: ControlPanelController
    public let presenter: ControlPanelPresenter
    
    
    public init(controlPanel: [ControlPanelSection]? = nil,
                notificationScheduler: LocalScheduler? = nil,
                analytics: GenericAnalytics? = nil) {
          
        let panelSections: [ControlPanelSection]
        
        if let controlPanel = controlPanel {
            panelSections = controlPanel
        } else {
            panelSections = StorageService().getControlPanel(from: "DefaultControlPanel")
        }
        
        var localScheduler: LocalScheduler?
        
        if let notificationScheduler = notificationScheduler {
            localScheduler = notificationScheduler
        } else {
            localScheduler = StorageService().getLocalScheduler(from: "DefaultLocalScheduler")
        }
        
        self.presenter = ControlPanelPresenter(panelSections: panelSections,
                                               localScheduler: localScheduler,
                                               analytics: analytics)
                                               
        self.view = ControlPanelController(output: presenter)
        presenter.view = view
    }
}
