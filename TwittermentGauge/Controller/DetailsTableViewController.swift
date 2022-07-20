//
//  DetailsTableViewController.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 3/21/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import UIKit
import CoreData

class DetailTableViewController: UIViewController {
    @IBOutlet var tweetDetailTableView: UITableView!
    let cellIdentifier = "PredictionCell"
    var dataController: DataController!
    var fetchedResultsFromDB: [TwitterSearchRequest]? = nil
    var refreshControl = UIRefreshControl()
    var tweets = Array<Tweet>()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetDetailTableView.delegate = self
        tweetDetailTableView.dataSource = self
        tweetDetailTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tweetDetailTableView.addSubview(refreshControl)
        
        let fetchRequest: NSFetchRequest<TwitterSearchRequest> = TwitterSearchRequest.fetchRequest()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "searchDT", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResult = try? dataController.viewContext.fetch(fetchRequest) {
            fetchedResultsFromDB = fetchResult
        }
        
        if let fetchedResultsFromDB = fetchedResultsFromDB?.first {
            for t in fetchedResultsFromDB.tweets!.allObjects {
                let tt = t as! Tweet
                tweets.append(tt)
            }
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        tweetDetailTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
}

extension DetailTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetDetailTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PredictionCell
        cell.tweet.text = tweets[indexPath.row].text
        cell.tweetLabel.text = tweets[indexPath.row].sentimentLabel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.row]
        let label = tweets[indexPath.row].sentimentLabel
        
        let modifyPredictionVC = self.storyboard?.instantiateViewController(withIdentifier: "ModifyPredictionVC") as! ModifyPredictionController
        modifyPredictionVC.tweet = tweet
        modifyPredictionVC.label = label
        modifyPredictionVC.dataController = dataController
        
        self.present(modifyPredictionVC, animated: true, completion: nil)
    }
}
