//
//  Date+format.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 05/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedDateString() -> String {
        let formatter = DateFormatter()
        if Date().timeIntervalSince(self) > 24*60*60 {
            formatter.dateStyle = .short
        } else {
            formatter.timeStyle = .short
        }
        return formatter.string(from: self)
    }
}
