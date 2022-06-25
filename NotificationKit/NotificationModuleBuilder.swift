import Foundation

public final class NotificationModuleBuilder {
    
    public let view: ControlPanelController
    public let presenter: ControlPanelPresenter
    
    
    public init(controlPanel: [ControlPanelSection]? = nil,
                analytics: GenericAnalytics? = nil) {
          
        let panelSections: [ControlPanelSection]
        
        if let controlPanel = controlPanel {
            panelSections = controlPanel
        } else {
            panelSections = StorageService().getControlPanel()
        }
        
        self.presenter = ControlPanelPresenter(
            panelSections: panelSections,
            analytics: analytics
        )
                                               
        self.view = ControlPanelController(output: presenter)
        presenter.view = view
    }
}
