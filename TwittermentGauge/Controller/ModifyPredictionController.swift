//
//  ModifyPredictionController.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 4/19/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ModifyPredictionController: UIViewController {
    //    var tweet: TwitttermentGaugeInput!
    var tweet: Tweet!
    var label: String!
    var dataController: DataController!
    let endpoint: String = "http://localhost:8080/api/tweets"
    
    @IBOutlet var tweetLabel: UILabel!
    @IBOutlet var labelLabel: UILabel!
    @IBOutlet var posButton: UIButton!
    @IBOutlet var negButton: UIButton!
    @IBOutlet var neutralButton: UIButton!
    @IBOutlet weak var uploadBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        posButton.isEnabled = false
        negButton.isEnabled = false
        neutralButton.isEnabled = false
        saveBtn.isEnabled = false
        
        tweetLabel.text = tweet.text
        labelLabel.text = label
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        let params: Parameters = [
            "text": tweet.text!,
            "label": tweet.sentimentLabel!
        ]
        
        AF.request(endpoint,
                   method: HTTPMethod.post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: nil
        )
        .validate(statusCode: 200 ..< 299)
        .responseData{
            (response) in
            switch response.result {
                case .success(let data):
                    self.showAlert(title: "Thanks!", message: "Thank you for taking the time to correct and share the sentiment clasification. Your input will be used to re-train and improve the classifier in the next version.")
                case .failure(let error):
                    self.showAlert(title: "connection error!", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        self._save()
        showAlert(title: "Saved!", message: "Change was saved!")
    }
    
    private func _save() {
        tweet.sentimentLabel = labelLabel.text
        try? dataController.viewContext.save()
    }
    
    @IBAction func change(_ sender: Any) {
        posButton.isEnabled = true
        negButton.isEnabled = true
        neutralButton.isEnabled = true
        saveBtn.isEnabled = true
    }
    
    @IBAction func pos(_ sender: Any) {
        labelLabel.text = "Pos"
        self._save()
    }
    
    @IBAction func neg(_ sender: Any) {
        labelLabel.text = "Neg"
        self._save()
    }
    
    @IBAction func neutral(_ sender: Any) {
        labelLabel.text = "Neutral"
        self._save()
    }
}

