//
//  SentimentPredictor.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 4/2/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import Foundation
import CoreML


struct SentimentPredictor {
    let santimentClassifier = TwitttermentGauge()
    var labels: [String] = [String]()
    
    mutating func makePrediction(with tweets: [TwitttermentGaugeInput]) -> (Int?, [String]) {
        do {
            let predictions = try self.santimentClassifier.predictions(inputs: tweets)
            var santimentScore = 0
            for prediction in predictions {
                labels.append(prediction.label)
                let santiment = prediction.label
                if santiment == "Pos" {
                    santimentScore += 1
                }
                else if santiment == "Neg" {
                    santimentScore -= 1
                }
            }
            
            return (santimentScore, labels)
        } catch {            
            return (nil, labels)
        }
    }
}
