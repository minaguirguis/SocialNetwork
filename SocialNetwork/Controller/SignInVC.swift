//
//  ViewController.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 3/25/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        //below we are requesting access just to the user's facebook email
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MINA: Unable to authenticate with facebook - \(error)")
            } else if result?.isCancelled == true {
                print("MINA: User cancelled Facebook authentication")
            } else {
                print("MINA: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)//getting the user's credentials
                
                self.firebaseAuth(credential)
                
            }
            //we put "MINA" in the error messages so when you type "MINA" you only see messages that have that name in the error message
        
        }
    }
    
    func firebaseAuth(_ credenatial: AuthCredential) {
        Auth.auth().signIn(with: credenatial) { (user, error) in
            if error != nil {
                print("MINA: Unable to authenticate with Firebase - \(error)")
            } else {
                print("MINA: Successfully authenticated with Firebase")
            }
        }
    }
    
    
    
    

}

