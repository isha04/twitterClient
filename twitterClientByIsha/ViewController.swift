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
    
    
    func handleTwitterButtonTapped() {
        TWTRTwitter.sharedInstance().logIn { (session, err) in
            if let err = err {
                self.alertWithTitle(title: "Error", message: "Failed to log in with Twitter with error: \(err)")
                return
            }
            guard let session = session else { return }
            self.twitterSession = session
            self.signIntoFirebaseWithTwitter()
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
        view.addSubview(logInButton)
        handleTwitterButtonTapped()
        getTweets()
    }
    
    let logInButton = TWTRLogInButton(logInCompletion: { session, error in
        if (session != nil) {
            let authToken = session?.authToken
            let authTokenSecret = session?.authTokenSecret
            print("this is token nd secret", authToken as! String, authTokenSecret as! String)
        } else {
                // ...
        }
    })
    



}

