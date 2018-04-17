//
//  TweetsViewController.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 16.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import UIKit
import TwitterKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private static let kTweetCell = "TweetCell"
    
    @IBOutlet weak var tweetsSearchBar: UISearchBar!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    private var tweets:[TWTRTweet] = []
    
    //main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        tweetsSearchBar.delegate = self
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self

        tweetsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    //SearchBar delegation
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchedText = searchBar.text else { return }
        
        searchKeyWord(keyWord: searchedText)
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //tableview/missing results are hidden when the user is typing
        tweetsTableView.isHidden = true
        noResultsLabel.isHidden = true
    }

    //Table View Delegation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetsViewController.kTweetCell, for: indexPath as IndexPath)
        let currentTweet = tweets[indexPath.row]
        
        //update current cell
        if let currentCell = cell as? TTTweetCell {
            currentCell.tweetView?.configure(with: currentTweet)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /**
     Send a query to Twitter's API with a given keyword.
     - Parameter keyWord: String value which can be null.
     */
    func searchKeyWord(keyWord: String?){
        guard let searchWord = keyWord, searchWord != "" else {
            updateTweeets(newTweets: [])
            return
        }
        
        //show activity indicator during the query
        activityIndicator.startAnimating()
        
        //send a search query. Update tableView when receiving a response, stop the activity indicator.
        TTCommunicationManager.getTweetsWith(keyword: searchWord) { [weak self] (error, currentTweets) in
            guard let weakSelf = self else { return }
            
            var newTweets: [TWTRTweet] = []
            if error == nil, let tweets = currentTweets {
                newTweets = tweets
            }
            
            DispatchQueue.main.async {
                weakSelf.updateTweeets(newTweets: newTweets)
                weakSelf.activityIndicator.stopAnimating()
                weakSelf.noResultsLabel.isHidden = newTweets != []
            }
        }
    }
    
    /**
     Updates the tableView with given tweets
     - Parameter newTweets: array of TWTRTweet objects. If it is empty the tableView is hidden.
     */
    private func updateTweeets(newTweets: [TWTRTweet]) {
        if newTweets == [] {
            tweetsTableView.isHidden = true
        }else{
            tweetsTableView.isHidden = false
        }
        tweets = newTweets
        tweetsTableView.reloadData()
    }
}
