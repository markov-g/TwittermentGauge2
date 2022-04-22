//
//  PredictionCell.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 4/9/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit

class PredictionCell: UITableViewCell {
    
    @IBOutlet weak var tweetImg: UIImageView!
    @IBOutlet weak var tweet: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var cell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        
        cell.isUserInteractionEnabled = false
        cell.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func handleCellTap(_ sender: UITapGestureRecognizer) {
        let app = UIApplication.shared
        //TODO: Handle Tap
        debugPrint("TODO: Handle tap")
    }
}
