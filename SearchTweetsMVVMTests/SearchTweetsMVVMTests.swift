//
//  SearchTweetsMVVMTests.swift
//  SearchTweetsMVVMTests
//
//  Created by Shibili Areekara on 11/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import XCTest
@testable import SearchTweetsMVVM

class SearchTweetsMVVMTests: XCTestCase {

    func testTweetViewModel() {
        let user = UserDetail(name: "Shibili", screen_name: "AreekaraShibili", id_str: "", profile_image_url: "")
        let media = Media(media_url_https: "")
        let entities = Entities(media: [media])
        let tweet = Tweets(text: "Shibili", created_at: "", favorite_count: 77, retweet_count: 7, user: user, entities: entities)

        let tweetViewModel = TweetViewModel(tweet: tweet)

        /// write down test cases here , few sample cases given below

        XCTAssertEqual(tweet.text, tweetViewModel.text)
        XCTAssertEqual(tweetViewModel.handleAndcreatedAt, "@\(tweet.user?.screen_name ?? "")")
    }

    func testNilCaseFormattedString() {
        let date = Date().getFormattedDateString()
        XCTAssertNotNil(date)
    }

    func testRequestInitialisation() {
        let sampleRequest = Request(search: "Shibili Areekara", count: 10)

        XCTAssertEqual(sampleRequest.parameters["q"], "Shibili Areekara")
        XCTAssertEqual(sampleRequest.parameters["count"], "10")
    }

}
