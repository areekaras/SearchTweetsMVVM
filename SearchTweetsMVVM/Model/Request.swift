//
//  Request.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 02/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation

public class Request: NSObject {
    public let requestType: String
    public let parameters: [String: String]
    
    public typealias PropertyList = Any
    
    private var min_id: String?
    private var max_id: String?
    
    public init(_ requestType: String, _ parameters: Dictionary<String, String> = [:]) {
        self.requestType = requestType
        self.parameters = parameters
    }
    
    public convenience init(search: String, count: Int = 0, resultType: SearchResultType = .recent) {
        
        var parameters = [TwitterKey.query: search]
        if count > 0 {
            parameters[TwitterKey.count] = "\(count)"
        }
        
        switch resultType {
        case .recent:
            parameters[TwitterKey.resultType] = TwitterKey.resultTypeRecent
        case .popular:
            parameters[TwitterKey.resultType] = TwitterKey.resultTypePopular
        }
        
        self.init(TwitterKey.searchForTweets, parameters)
    }
    
    public func fetchTweets(_ handler: @escaping ([Tweets]) -> Void) {
        
        fetch { results in
            var tweets = [Tweets]()
            
            if let searchResult = results as? SearchResult {
                print("\n\n**parsig success\n\n")
                
                if let tweetsArray = searchResult.statuses {
                    for tweet in tweetsArray {
                        tweets.append(tweet)
                    }
                }
            }
            handler(tweets)
        }
    }
    
    public func fetch(_ handler: @escaping (PropertyList?) -> Void) {
        performSearchRequest(handler: handler)
    }
    
    // generates a request for older Tweets than were returned by self
    // only makes sense if self has completed a fetch already
    // only makes sense for requests for Tweets
    public var older: Request? {
        if min_id == nil {
            if parameters[TwitterKey.maxID] != nil {
                return self
            }
        } else {
            return modifiedRequest(parametersToChange: [TwitterKey.maxID: min_id!])
        }
        return nil
    }
    
    // generates a request for newer Tweets than were returned by self
    // only makes sense if self has completed a fetch already
    // only makes sense for requests for Tweets
    public var newer: Request? {
        if max_id == nil {
            if parameters[TwitterKey.sinceID] != nil {
                return self
            }
        } else {
            return modifiedRequest(parametersToChange: [TwitterKey.sinceID: max_id!], clearCount: true)
        }
        return nil
    }
    
    // MARK: - Internal Implementation
    func performSearchRequest(handler: @escaping (PropertyList?) -> Void) {
        performSearch(handler: handler)
    }
    
    func performSearch(handler: @escaping (PropertyList?) -> Void) {
        if client != nil {
            let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
            let params = parameters
            var clientError: NSError?
            
            let request = client?.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client?.sendTwitterRequest(request!) { (_, data, _) -> Void in
                
                var propertyListResponse: PropertyList?
                if data != nil {
                    
                    propertyListResponse = try? JSONDecoder().decode(SearchResult.self, from: data!)
                    
                    if propertyListResponse == nil {
                        let error = "Couldn't parse JSON response."
                        self.log(error)
                        propertyListResponse = error
                    }
                } else {
                    let error = "No response from Twitter."
                    self.log(error)
                    propertyListResponse = error
                }
                self.synchronize {
                    self.captureFollowonRequestInfo(propertyListResponse)
                }
                handler(propertyListResponse)
                
            }
        }
    }
    
    // modifies parameters in an existing request to create a new one
    
    private func modifiedRequest(parametersToChange: Dictionary<String, String>, clearCount: Bool = false) -> Request {
        var newParameters = parameters
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        if clearCount { newParameters[TwitterKey.count] = nil }
        return Request(requestType, newParameters)
    }
    
    // captures the min_id and max_id information
    // to support requestForNewer and requestForOlder
    
    private func captureFollowonRequestInfo(_ propertyListResponse: PropertyList?) {
        if let responseDictionary = propertyListResponse as? NSDictionary {
            self.max_id = responseDictionary.value(forKeyPath: TwitterKey.SearchMetadata.maxID) as? String
            if let next_results = responseDictionary.value(forKeyPath: TwitterKey.SearchMetadata.nextResults) as? String {
                for queryTerm in next_results.components(separatedBy: TwitterKey.SearchMetadata.separator) {
                    if queryTerm.hasPrefix("?\(TwitterKey.maxID)=") {
                        let next_id = queryTerm.components(separatedBy: "=")
                        if next_id.count == 2 {
                            self.min_id = next_id[1]
                        }
                    }
                }
            }
        }
    }
    
    // debug println with identifying prefix
    
    private func log(_ whatToLog: Any) {
        debugPrint("TwitterRequest: \(whatToLog)")
    }
    
    // synchronizes access to self across multiple threads
    
    private func synchronize(_ closure: () -> Void) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    // keys in Twitter responses/queries
    struct TwitterKey {
        static let count = "count"
        static let query = "q"
        static let tweets = "statuses"
        static let resultType = "result_type"
        static let resultTypeRecent = "recent"
        static let resultTypePopular = "popular"
        static let geocode = "geocode"
        static let searchForTweets = "search/tweets"
        static let maxID = "max_id"
        static let sinceID = "since_id"
        
        struct SearchMetadata {
            static let maxID = "search_metadata.max_id_str"
            static let nextResults = "search_metadata.next_results"
            static let separator = "&"
        }
    }
    
    public enum SearchResultType: Int {
        case recent
        case popular
    }
    
}
