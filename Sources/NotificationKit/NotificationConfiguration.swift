//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation
import UIKit


struct NotificationConfiguration {
    
    let showCondition: Bool
    let enableLabelText: String
    let enableButtonTitle: String
    let dismissButtonTitle: String
    let alertViewBackgroundColor: UIColor // UIColor(rgb: 0xF4F4F4)
    let labelColor: UIColor // UIColor(rgb: 0x555555)
    let appOpenCount: Int?
    let notificationTitles: [String]//["notificationStandardTitle".localized()]
    let notificationBodies: [String]//["notificationStandardBody".localized()]
}



