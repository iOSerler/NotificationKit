//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation

public struct LocalScheduler: Decodable {
    
    let id: String
    let titles: [String]
    let bodies: [String]
    let attachmentNames: [String]
    let schedule: [Double]
}
