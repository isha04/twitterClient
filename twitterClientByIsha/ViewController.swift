//
//  ViewController.swift
//  twitterClientByIsha
//
//  Created by Isha on 9/7/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import Alamofire
import TwitterKit


class ViewController: UIViewController {
    
    var twitterSession: TWTRSession?
    var name: String? = ""
    var username: String? = ""
    var email: String? = ""
    var profileImage: UIImage?
    let twitterButton = UIButton(type: .system)
    var access_token = ""

    
    @objc func handleTwitterButtonTapped() {
        let store = TWTRTwitter.sharedInstance().sessionStore
        let lastSession = store.session()
        
//         This checks if you've logged in using Twitter. If it's nil then it'll show login page else just prints the email. This also tells you, you've user logged in so that you can show something else instead of login screen.
        guard lastSession == nil else {
            print("this is session info \(lastSession?.userID), \(lastSession?.authToken)")
            performSegue(withIdentifier: "showTweet", sender: self)
            return
        }
        
        TWTRTwitter.sharedInstance().logIn { (session, err) in
            if let err = err {
                self.alertWithTitle(title: "Error", message: "Failed to log in with Twitter with error: \(err)")
                return
            }
            guard let session = session else { return }
            self.twitterSession = session
            self.access_token = session.authToken
            print("this is session info \(session.userID), \(session.authToken)")
            self.performSegue(withIdentifier: "showTweet", sender: self)
        }
    }
    
    // Code for fetching user email address.
    func fetchUserEmailAddress() {
        let client = TWTRAPIClient.withCurrentUser()
        
        client.requestEmail { (email, error) in
            guard error == nil else {
                print(error!)
                return
            }
            print("Email Address: \(email ?? "")")
        }
    }
    
    //this crashes, so i tried the methods in the documentation demo "https://github.com/twitter/twitter-kit-ios/blob/master/DemoApp/DemoApp/Demos/Timelines%20Demo/ListTimelineViewController.swift"
    
    func fetchTweet() {
        let client = TWTRAPIClient.withCurrentUser()
        client.loadTweets(withIDs: [0...20]) { (tweet, error) in
            guard error == nil else {
                print(error!)
                return
            }
            print(tweet as Any)
        }
    }
    
    
    func alertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(twitterButton)
        twitterButton.translatesAutoresizingMaskIntoConstraints = false
        
        twitterButton.setTitle("Log in using Twitter", for: .normal)
        
        NSLayoutConstraint.activate([
            twitterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            twitterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        twitterButton.addTarget(self, action: #selector(handleTwitterButtonTapped), for: .touchUpInside)
    }

}

