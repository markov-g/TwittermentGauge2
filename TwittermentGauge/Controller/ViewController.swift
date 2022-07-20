//
//  ViewController.swift
//
//

import UIKit
import CoreData
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var explainBtn: UIButton!
    @IBOutlet weak var predictBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var clearBarBtn: UIBarButtonItem!
    @IBOutlet weak var helpBarBtn: UIBarButtonItem!
    
    var dataController: DataController!
    var tweetSentimentSequenceBundle: Zip2Sequence<[TwitttermentGaugeInput], [String]>? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        self.sentimentLabel.text = "😐"
        self.textField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.predictBtn.isEnabled = false
        self.predictBtn.tintColor = UIColor.gray
        self.explainBtn.isEnabled = false
        self.predictBtn.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
    }

    @IBAction func clearPressed(_ sender: UIBarButtonItem) {
        for entity in [Tweet.self, TwitterSearchRequest.self] {
        // create the delete request for the specified entity
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = entity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            // get reference to the persistent container
            let persistentContainer = dataController.persistentContainer

            // perform the delete
            do {
                try persistentContainer.viewContext.execute(deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
        
        let controller = UIAlertController()
        controller.title = "CoreData wiped!"
        controller.message = "All stored searches and related tweets have been deleted from this device!"

        let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
        }

        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func helpPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        if textField.text == "" {
            showAlert(title: "Empty Search String", message: "Please provide a search term.")
            return
        }
        let fetcher = TweetFetcher(dataController: dataController)
        fetcher.fetchTweets(with: textField.text, completion: tweetHandlerT(tw:error:))
    }
    
    func tweetHandlerT(tw: [TwitttermentGaugeInput]?, error: Error?) -> Void {
        var predictor = SentimentPredictor()
        if let tw = tw {
            let sentimentPrediction = predictor.makePrediction(with: tw)
            assert(tw.count == sentimentPrediction.1.count)
                        
            tweetSentimentSequenceBundle = zip(tw, sentimentPrediction.1)
            if let data = tweetSentimentSequenceBundle {
                saveToCoreDataStore(data: data)
            }
            
            updateUI(with: sentimentPrediction.0!)
        }
        else {
            showAlert(title: "Couldn't fetch tweets", message: error!.localizedDescription)
        }
    }
    
    private func saveToCoreDataStore(data: Zip2Sequence<[TwitttermentGaugeInput], [String]>) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-hh-mm"
        let dateString = dateFormatter.string(from: currentDate)
        
        let twittertSearchRequest = TwitterSearchRequest(context: dataController.viewContext)
        twittertSearchRequest.searchDT = dateString
        twittertSearchRequest.searchKey = textField.text
        
        var tweetDataArray: [Tweet] = [Tweet]()
        var tweetData: Tweet
        
        for (_, t) in data.enumerated() {
            tweetData = Tweet(context: dataController.viewContext)
            tweetData.text = t.0.text
            tweetData.sentimentLabel = t.1
        
            tweetData.searchRequest = twittertSearchRequest
            tweetDataArray.append(tweetData)
            
            twittertSearchRequest.addToTweets(tweetData)
//            try? dataController.viewContext.save()
        }
        
        try? dataController.viewContext.save()
    }
    
    func updateUI(with santimentScore: Int) {
        self.explainBtn.isEnabled = true
        
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
            if let controller = segue.destination as? DetailTableViewController {
                controller.dataController = dataController
                self.explainBtn.isEnabled = true
            }
        }
        if segue.identifier == "getHelp" {
            if let controller = segue.destination as? HelpViewController {
                controller.dataController = dataController
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.predictBtn.isEnabled = true
        return true
    }
}
