//
//  HelpViewController.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 7/18/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit
import CoreData

class HelpViewController: UIViewController {
    var dataController: DataController!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        textView.text = "This application has the goal to support your decision making (e.g. investment decisions) with Twitter Sentiment Analysis. \n\n"
        
        textView.text += "USAGE: \n"
        textView.text += "1. Start by adding some search text in the search box and clicking the 'Predict!' button. You will get result about the general sentiment on Twitter with regards to your search term.\n"
        textView.text += "2. If you want to see details, click the 'Explain' button.\n\n\n"
        
        textView.text += "Note: Your searches and results are being saved for the purpose of allowig you to upload your modified sentiments to the server to improve the classification algorithm. To do so: \n"
        textView.text += "3. On the Prediction Details screen, you can click on any tweet and modify the prediction if you disagree with it. Clicking 'Save' will automatically upload the result to our server. \n\n"
        textView.text += "4. To delete all saved searches and related tweets, you can press the ✖️ button on the main screen."        
    }
}
