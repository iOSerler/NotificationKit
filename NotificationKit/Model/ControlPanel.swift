//
//  File.swift
//  
//
//  Created by Daniya on 15/02/2022.
//

import Foundation

public struct ControlPanelSection : Codable {
    let id: String
    let title: String
    let type: String
    var items: [ControlPanelItem]
}
public struct ControlPanelItem : Codable {
    let id: String
    let type: String
    let title: String
}

enum ControlPanelType: String {
    case switchable
}
