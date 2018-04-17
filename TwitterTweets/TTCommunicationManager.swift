//
//  TTCommunicationManager.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 16.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import Foundation
import TwitterKit

enum CommunicationErrors {
    case ConnectionError
    case ParsingError
    case TweetsError
}

class TTCommunicationManager {
    private static let twitterKey = "J9TyqX8lYwKf63KpPuSHcaVIj"
    private static let privateKey = "UWtRtNS1H5dTJ5BxUMxLNPyiUOW4ScdTTuas0pK1kMgwzlQCRv"
    private static let twitterUrl = "https://api.twitter.com/1.1/search/tweets.json"
    
    /**
     Start communication with Twitter's API
     */
    class func startTwitter(){
        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterKey, consumerSecret: privateKey)
    }
    
    /**
     Send query with searched word.
     - Parameter keyword: Searched String.
     - Parameter completion: Block which will be executed when the response is received or any error occur
     */
    class func getTweetsWith(keyword: String, completion: ((CommunicationErrors?, [TWTRTweet]?) -> Void)?){
        let client = TWTRAPIClient()
        let params = ["q": keyword]
        var clientError : NSError?
        let request = client.urlRequest(withMethod: "GET", urlString: twitterUrl, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) in
            if connectionError != nil {
                completion?(.ConnectionError, nil)
                return
            }
            
            //try to get json object and convert it to array with TWTRTweet objects
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any], let statuses = json["statuses"] as? [Any], let currentTweets = TWTRTweet.tweets(withJSONArray: statuses) as? [TWTRTweet] {
                    completion?(nil, currentTweets)
                }else{
                    completion?(.TweetsError, nil)
                }
            } catch {
                completion?(.ParsingError, nil)
            }
        }
    }
}
