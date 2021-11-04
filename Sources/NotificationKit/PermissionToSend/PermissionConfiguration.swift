//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation
import UIKit


struct PermissionConfiguration {
    
    let enableLabelText: String
    let enableButtonTitle: String
    let dismissButtonTitle: String
    let alertViewBackgroundColor: UIColor
    let labelColor: UIColor
    let appOpenCount: Int
    let permissionAlertType: PermissionAlertType
    
    init(enableLabelText: String = "Please enable notifications",
         enableButtonTitle:String = "Enable",
         dismissButtonTitle: String = "Dismiss",
         alertViewBackgroundColor: UIColor = UIColor.white,
         labelColor: UIColor = UIColor.darkText,
         appOpenCount: Int = 1,
         permissionAlertType: PermissionAlertType = .system
    ) {
        self.enableLabelText = enableLabelText
        self.enableButtonTitle = enableButtonTitle
        self.dismissButtonTitle = dismissButtonTitle
        self.alertViewBackgroundColor = alertViewBackgroundColor
        self.labelColor = labelColor
        self.appOpenCount = appOpenCount
        self.permissionAlertType = permissionAlertType
    }
}
