//
//  TweetFetcher.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 3/30/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import Swifter
import CoreData

struct TweetFetcher {
    let tweetCount = 100
    let dataController: DataController
    
    init(dataController: DataController) {
        self.dataController = dataController        
    }
    
            
    func fetchTweets(with searchText: String?, completion: @escaping ([TwitttermentGaugeInput]?, Error?) -> Void) {
        let cm = CredentialsManager()
        let key = cm.fetchSecretsPlist["API Key"]!
        let secret = cm.fetchSecretsPlist["API Secret"]!
        
        let swifter = Swifter(consumerKey: key, consumerSecret: secret)
        
        if let searchText = searchText {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
                
                
                var tweets: [TwitttermentGaugeInput] = [TwitttermentGaugeInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TwitttermentGaugeInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                completion(tweets, nil)
            } failure: { (error) in
                completion(nil, error)
            }
        }
    }
}
