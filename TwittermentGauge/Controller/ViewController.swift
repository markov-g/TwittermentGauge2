//
//  ViewController.swift
//
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    var tweetSentimentSequenceBundle: Zip2Sequence<[TwitttermentGaugeInput], [String]>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        let fetcher = TweetFetcher()
        fetcher.fetchTweets(with: textField.text, completion: tweetHandlerT(tw:error:))
    }
    
    func tweetHandlerT(tw: [TwitttermentGaugeInput]?, error: Error?) -> Void {
        var predictor = SentimentPredictor()
        if let tw = tw {
            let sentimentPrediction = predictor.makePrediction(with: tw)
            // TODO: Make tweets a dictionary add Add labels to respective tweets for explanation
            assert(tw.count == sentimentPrediction.1.count)
            tweetSentimentSequenceBundle = zip(tw, sentimentPrediction.1)
            
            updateUI(with: sentimentPrediction.0!)
        }
        else {
            showFailure(title: "Couldn't fetch tweets", message: error!.localizedDescription)
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

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predictions" {
            if let navVC = segue.destination as? UINavigationController {
                if let controller = navVC.topViewController as? DetailTableViewController {
                    controller.tweetSentimentSequenceBundle = tweetSentimentSequenceBundle
                }
            }
        }
    }
}




