//
//  tweetsViewController.swift
//  twitterClientByIsha
//
//  Created by Isha on 9/8/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import TwitterKit

class tweetsViewController: TWTRTimelineViewController, TWTRTimelineDelegate {

    @IBOutlet weak var tweetTable: UITableView!
    
    var tweets: [Any] = [] {
        didSet {
            tweetTable.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = TWTRAPIClient.withCurrentUser()
        self.dataSource = TWTRListTimelineDataSource(listSlug: "twitter-kit", listOwnerScreenName: "stevenhepting", apiClient: client)
        self.timelineDelegate = self;
        //SVProgressHUD.setDefaultStyle(.dark)
        
        self.showTweetActions = true
        self.view.backgroundColor = .lightGray
    }
        
    func timelineDidBeginLoading(_ timeline: TWTRTimelineViewController) {
        print("Began loading Tweets.")
        //SVProgressHUD.show(withStatus: "Loading")
    }
    
    func timeline(_ timeline: TWTRTimelineViewController, didFinishLoadingTweets tweets: [Any]?, error: Error?) {
        if error != nil {
            print("Encountered error \(error!)")
//            SVProgressHUD.showError(withStatus: "Error")
//            SVProgressHUD.dismiss(withDelay: 1)
        } else {
            self.tweets = tweets!
            print("Finished loading \(String(describing: tweets))")
//            SVProgressHUD.showSuccess(withStatus: "Finished");
//            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        let cell = tweetTable.dequeueReusableCell(withIdentifier: "tweets", for: indexPath)
        return cell
    }
}
