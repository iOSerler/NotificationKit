//
//  File.swift
//  
//
//  Created by Daniya on 04/11/2021.
//

import Foundation

public struct LocalNotificationConfiguration {
    
    let notificationTitles: [String]
    let notificationBodies: [String]
    let attachmentNames: [String]
    let daysAfterLastLaunchOnWhichToSend: [Double]
    
    public init(
         notificationTitles: [String] = ["Hello!"],
         notificationBodies: [String] = ["Haven't seen you for some time!"],
         attachmentNames: [String] = ["Thumbnail"],
         daysAfterLastLaunchOnWhichToSend: [Double] = [
//            0.0001, /// FIXME: only for testing
            1,2,3, /// send daily for first three days
            5,7, /// then switch to every other day
            10,13,16,19, /// then send a notification once in three days
            26,34,41, /// then once a week
            55,69, /// then every other week
            99,129,159,189,219,249,279,309,339,369,399,429 /// then keep it monthly for the rest of the year
        ]
    ) {
        self.notificationTitles = notificationTitles
        self.notificationBodies = notificationBodies
        self.attachmentNames = attachmentNames
        self.daysAfterLastLaunchOnWhichToSend = daysAfterLastLaunchOnWhichToSend
    }
}
