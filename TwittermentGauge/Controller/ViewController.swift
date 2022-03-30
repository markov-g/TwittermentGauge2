//
//  ViewController.swift
//
//

import UIKit
import Swifter
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount: Int = 100
    
    let santimentClassifier = TwitttermentGauge()
    let swifter = Swifter(consumerKey: fetchSecretsPlist()["API Key"]!, consumerSecret: fetchSecretsPlist()["API Secret"]!)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    func fetchTweets() {
        if let searchTest = textField.text {
            swifter.searchTweet(using: searchTest, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
                
                var tweets: [TwitttermentGaugeInput] = [TwitttermentGaugeInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TwitttermentGaugeInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                if tweets.count > 10 {
                    self.makePrediction(with: tweets)
                }
                else {
                    fatalError("Insufficient number of sweetes : \(tweets.count) < 10.")
                }
                
            } failure: { (error) in
                print("There was an error with the Twitter API request: \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TwitttermentGaugeInput]) {
        do {
            let predictions = try self.santimentClassifier.predictions(inputs: tweets)
            
            var santimentScore = 0
            for prediction in predictions {
                let santiment = prediction.label
                if santiment == "Pos" {
                    santimentScore += 1
                }
                else if santiment == "Neg" {
                    santimentScore -= 1
                }
            }
            
            updateUI(with: santimentScore)
        } catch {
            print("Error making predictions: \(error)")
        }
    }
    
    func updateUI(with santimentScore: Int) {
        if santimentScore > 15 {
            self.sentimentLabel.text = "😍"
        } else if santimentScore > 7 {
            self.sentimentLabel.text = "😁"
        } else if santimentScore > 0 {
            self.sentimentLabel.text = "🤨"
        } else if santimentScore > -7 {
            self.sentimentLabel.text = "😞"
        } else if santimentScore > -15 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
}


func fetchSecretsPlist() -> Dictionary<String, String> {
    guard let secretsFile = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
        fatalError("Could not find secrets file")
    }
    let url = URL(fileURLWithPath: secretsFile)
    let data = try! Data(contentsOf: url)
    guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {
        fatalError("Could not fetch information from plist:")
    }
    
    return plist
}




