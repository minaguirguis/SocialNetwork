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
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("MINA: ID found in keychain")
            performSegue(withIdentifier: SEGUE_IDENTIFIER, sender: nil)
        }
    }
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        //below we are requesting access just to the user's facebook email
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MINA: Unable to authenticate with facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("MINA: User cancelled Facebook authentication")
            } else {
                print("MINA: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)//getting the user's credentials
                
                self.firebaseAuth(credential)
                
            }
            //we put "MINA" in the error messages so when you type "MINA" in the console ee, you only see messages that have that name in the error message
        
        }
    }
    
    func firebaseAuth(_ credenatial: AuthCredential) {
        Auth.auth().signIn(with: credenatial) { (user, error) in
            if error != nil {
                print("MINA: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("MINA: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": user.providerID]//from Databse
                    self.completeSignIN(id: user.uid, userData: userData)
                }
            }
        }
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text{
            
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("MINA: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]//from Databse
                        self.completeSignIN(id: user.uid, userData: userData)
                    }
                    
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MINA: Unable to authenticate with Firebase using email \(String(describing: error))")
                        } else {
                            print("MINA: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]//from Database
                                self.completeSignIN(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIN(id: String, userData: Dictionary<String, String>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        print("MINA: Successfully signed in and created user to FB")
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("MINA: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: SEGUE_IDENTIFIER, sender: nil)
    }

}

