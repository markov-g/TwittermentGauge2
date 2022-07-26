//
//  ViewController.swift
//
//

import UIKit
import CoreData
import SwiftyJSON

class MainViewController: UIViewController {
    
    @IBOutlet weak var explainBtn: UIButton!
    @IBOutlet weak var predictBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var clearBarBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var helpBarBtn: UIBarButtonItem!
    var frame_h: CGFloat = 0
    var frame_w: CGFloat = 0
    
    var dataController: DataController!
    var tweetSentimentSequenceBundle: Zip2Sequence<[TwitttermentGaugeInput], [String]>? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sentimentLabel.text = "😐"
        self.textField.text = ""
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.predictBtn.isEnabled = false
        self.predictBtn.tintColor = UIColor.gray
        self.explainBtn.isEnabled = false
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.predictBtn.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
        frame_h = view.frame.size.height
        frame_w = view.frame.size.width 
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
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
        textField.resignFirstResponder()
        if textField.text == "" {
            showAlert(title: "Empty Search String", message: "Please provide a search term.")
            return
        }
        
        self.activityIndicator.startAnimating()
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
        self.activityIndicator.stopAnimating()
        
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

extension MainViewController {
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

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.predictBtn.isEnabled = true
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: Keyboard Notifications
extension MainViewController {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        // scale the imageview to show the entire image rather than slide it
        view.frame.size.height = frame_h
        view.frame.size.height -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.size.height = frame_h
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
