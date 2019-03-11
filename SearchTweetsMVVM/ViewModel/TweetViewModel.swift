//
//  TweetViewModel.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 04/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation
import UIKit

struct TweetViewModel {
    
    let text: String
    let fullName: String
    var handleAndcreatedAt: String
    let retweetCount: String
    let favoriteCount: String
    
    var profileImageUrl: String?
    var tweetImageUrl: String?
    
    //Dependency Injection
    init(tweet: Tweets) {
        self.text = tweet.text ?? ""
        self.fullName = tweet.user?.name ?? ""
        
        self.retweetCount = " \(tweet.retweet_count ?? 0)"
        self.favoriteCount = " \(tweet.favorite_count ?? 0)"
        
        self.handleAndcreatedAt = "@\(tweet.user?.screen_name ?? "")"
        if let createdAt = tweet.created_at {
            let twitterDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }()
            
            if let createdDate = twitterDateFormatter.date(from: createdAt) {
                let createdText = createdDate.getFormattedDateString()
                
                self.handleAndcreatedAt += " • \(createdText)"
            }
        }
        
//        if let profileImageURL = tweet.user?.profile_image_url {
//            self.profileImageView?.loadImageFromUrl(urlString: profileImageURL)
//        }
//
//        if let mediaItem = tweet.entities?.media {
//            if let mediaURL = mediaItem.first?.media_url_https {
//                self.tweetImageView?.loadImageFromUrl(urlString: mediaURL)
//            }
//        }
        
        self.profileImageUrl = tweet.user?.profile_image_url
        
        if let mediaItem = tweet.entities?.media {
            if let mediaURL = mediaItem.first?.media_url_https {
                self.tweetImageUrl = mediaURL
            }
        }
    }
    
}
