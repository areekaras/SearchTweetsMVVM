//
//  LoginViewController.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 03/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit
import TwitterKit

var client: TWTRAPIClient?

class LoginViewController: UIViewController {

    var loginButton: TWTRLogInButton!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialiseVC()
    }
    
    // MARK: - Functionalities
    
    private func initialiseVC () {
        
        if client != nil {
            self.presentTweetsTableViewController()
        } else {
            self.showTwitterLoginButton()
        }
    }
    
    private func showTwitterLoginButton() {
        loginButton = TWTRLogInButton(logInCompletion: { (session, error) in
            if let session = session {
                print("signed in as \(session.userName)")
                
                self.loginSuccessAction()
            } else {
                self.loginButton.isHidden = false
                
                let errorDescription = error?.localizedDescription ?? "unknown"
                print("error: \(errorDescription)")
            }
        })
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }
    
    private func loginSuccessAction () {
        
        client = TWTRAPIClient.withCurrentUser()
        
        DispatchQueue.main.async {
            self.loginButton.isHidden = true
            self.presentTweetsTableViewController()
        }
    }
    
    private func presentTweetsTableViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let initialViewController = storyboard.instantiateViewController(withIdentifier: "TweetsTableViewController") as?  UINavigationController else { return }
        self.present(initialViewController, animated: true, completion: nil)
    }
    
}
