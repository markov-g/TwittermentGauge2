//
//  UIViewController+Extensions.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 3/26/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension UIViewController {
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
