//
//  ModifyPredictionController.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 4/19/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit

class ModifyPredictionController: UIViewController {
//    var tweet: TwitttermentGaugeInput!
    var tweet: Tweet!
    var label: String!
    var dataController: DataController!
    
    @IBOutlet var tweetLabel: UILabel!
    @IBOutlet var labelLabel: UILabel!
    @IBOutlet var posButton: UIButton!
    @IBOutlet var negButton: UIButton!
    @IBOutlet var neutralButton: UIButton!
  
    override func viewDidAppear(_ animated: Bool) {
        posButton.isEnabled = false
        negButton.isEnabled = false
        neutralButton.isEnabled = false
        
        tweetLabel.text = tweet.text
        labelLabel.text = label
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func change(_ sender: Any) {
        posButton.isEnabled = true
        negButton.isEnabled = true
        neutralButton.isEnabled = true
    }
    
    @IBAction func pos(_ sender: Any) {
        labelLabel.text = "Pos"
    }
    
    @IBAction func neg(_ sender: Any) {
        labelLabel.text = "Neg"
    }
    
    @IBAction func neutral(_ sender: Any) {
        labelLabel.text = "Neutral"
    }
}

extension ModifyPredictionController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToPredictions" {
            if let navVC = segue.destination as? UINavigationController {
                if let controller = navVC.topViewController as? DetailTableViewController {
                    controller.dataController = dataController
                }
            }
        }
    }
}
