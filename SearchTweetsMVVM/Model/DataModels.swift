//
//  DataModels.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 02/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation
import UIKit

public struct SearchResult: Codable {
    let statuses: [Tweets]?
}

public struct Tweets: Codable {
    let text: String?
    let created_at: String?
    let favorite_count: Int?
    let retweet_count: Int?
    
    let user: UserDetail?
    
    let entities: Entities?
}

public struct UserDetail: Codable {
    let name: String?
    let screen_name: String?
    let id_str: String?
    let profile_image_url: String?
}

public struct Entities: Codable {
    let media: [Media]?
}

public struct Media: Codable {
    let media_url_https: String?
}
