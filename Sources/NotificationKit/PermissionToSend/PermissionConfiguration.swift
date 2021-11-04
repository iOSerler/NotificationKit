//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation
import UIKit


public struct PermissionConfiguration {
    
    let enableLabelText: String
    let enableButtonTitle: String
    let dismissButtonTitle: String
    let alertViewBackgroundColor: UIColor
    let labelColor: UIColor
    let permissionAlertType: PermissionAlertType
    let appOpenCount: Int
    let conditionWhenToAsk: (() -> Bool)
    
    public init(enableLabelText: String = "Please enable notifications",
                enableButtonTitle:String = "Enable",
                dismissButtonTitle: String = "Dismiss",
                alertViewBackgroundColor: UIColor = UIColor.white,
                labelColor: UIColor = UIColor.darkText,
                permissionAlertType: PermissionAlertType = .system,
                appOpenCount: Int = 1,
                conditionWhenToAsk: (()->Bool)? = nil
    ) {
        self.enableLabelText = enableLabelText
        self.enableButtonTitle = enableButtonTitle
        self.dismissButtonTitle = dismissButtonTitle
        self.alertViewBackgroundColor = alertViewBackgroundColor
        self.labelColor = labelColor
        self.appOpenCount = appOpenCount
        self.permissionAlertType = permissionAlertType
        if let conditionWhenToAsk = conditionWhenToAsk {
            self.conditionWhenToAsk = conditionWhenToAsk
        } else {
            self.conditionWhenToAsk = { appOpenCount % 2 == 1 }
        }
    }
}
