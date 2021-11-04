//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation

public protocol GenericAnalytics {
    func logEvent(_ eventName: String, properties: [String:Any]?)
    func setUserProperty(_ property: String, value: Any)
}
