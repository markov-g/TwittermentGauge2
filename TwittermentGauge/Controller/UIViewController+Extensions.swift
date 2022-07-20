//
//  UIViewController+Extensions.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 3/26/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController()
        alertVC.title = title
        alertVC.message = message
        let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
        }

        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
