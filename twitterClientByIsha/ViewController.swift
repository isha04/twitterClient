//
//  ViewController.swift
//  twitterClientByIsha
//
//  Created by Amarjeet on 9/7/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import Accounts
import Alamofire
import FirebaseAuth
import TwitterKit

class ViewController: UIViewController {
    
    var twitterSession: TWTRSession?
    var name: String? = ""
    var username: String? = ""
    
    var email: String? = ""
    
    var profileImage: UIImage?
    
    let twitterButton = UIButton(type: .system)
    
    @objc func handleTwitterButtonTapped() {
        
        let store = TWTRTwitter.sharedInstance().sessionStore
        
        let lastSession = store.session()
        
        // This checks if you've logged in using Twitter. If it's nil then it'll show login page else just prints the email. This also tells you, you've user logged in so that you can show something else instead of login screen.
        guard lastSession == nil else {
            self.fetchUserEmailAddress()
            print(lastSession!.userID, lastSession!.authToken)
            fetchTweet()
            return
        }
        
        TWTRTwitter.sharedInstance().logIn { (session, err) in
            if let err = err {
                self.alertWithTitle(title: "Error", message: "Failed to log in with Twitter with error: \(err)")
                return
            }
            guard let session = session else { return }
            
            self.twitterSession = session
            
            self.fetchUserEmailAddress()
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
    
    func fetchTweet() {
        let client = TWTRAPIClient.withCurrentUser()
        
        client.loadTweet(withID: "20") { (tweet, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            print(tweet!.author, tweet!.createdAt, tweet!.text)
        }
    }
    
    func signIntoFirebaseWithTwitter() {
        guard let twitterSession = twitterSession else { return }
        let credential = TwitterAuthProvider.credential(withToken: twitterSession.authToken, secret: twitterSession.authTokenSecret)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                self.alertWithTitle(title: "Sign up error", message: error.localizedDescription)
                return
            }
            self.fetchTwitterUser()
        }
    }
    
    func fetchTwitterUser() {
        guard let twitterSession = twitterSession else { return }
        let client = TWTRAPIClient()
        client.loadUser(withID: twitterSession.userID, completion: { (user, err) in
            if let err = err {
                self.alertWithTitle(title: "Twitter user error", message: err.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            self.name = user.name
            self.username = twitterSession.userName
            let profilePictureUrl = user.profileImageLargeURL
            guard let url = URL(string: profilePictureUrl) else {
                self.alertWithTitle(title: "Error", message: "Failed to fetch user")
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if err != nil {
                    guard let err = err else {
                        self.alertWithTitle(title: "Error", message: "Failed to fetch user")
                        return
                    }
                    self.alertWithTitle(title: "Fetch Error", message: err.localizedDescription)
                    return
                }
                guard let data = data else {
                    self.alertWithTitle(title: "Error", message: "Failed to fetch user")
                     return
                }
                self.profileImage = UIImage(data: data)
                print(self.name, self.username, profilePictureUrl)
                }
            
        })
    }
    
    func getTweets() {
        Alamofire.request("https://api.twitter.com/1.1/statuses/home_timeline.json").responseJSON(completionHandler: { response in
            guard let validResponse = response.result.value else { return }
            print(validResponse)
            
        })
        
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
    
    let logInButton = TWTRLogInButton(logInCompletion: { session, error in
        if (session != nil) {
            let authToken = session?.authToken
            let authTokenSecret = session?.authTokenSecret
            print("this is token nd secret", authToken ?? "", authTokenSecret ?? "")
        } else {
                // ...
        }
    })
    



}

