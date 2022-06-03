//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation
import UIKit

public enum PermissionAlertType: String {
    /// permissionAlertType
    case intrusive
    case nonintrusive
    case screen
    case system
}

public struct PermissionDialogue: Decodable {
    
    let id: String
    let enableLabelText: String
    let enableButtonTitle: String
    let dismissButtonTitle: String
    let alertViewHexColor: String
    let labelHexColor: String
    let permissionAlertType: String
    
    var alertViewBackgroundColor: UIColor {
        .white
    }
    
    var labelColor: UIColor {
        .black
    }
}
