//
//  FeedVCViewController.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 4/17/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)//add this to the array created above
                    }
                }
            }
            
            self.tableView.reloadData()//to refresh after getting data
        })
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count//number of cells to be the number of objects in our array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: POSTCELL_REF) as? PostCell{
            cell.configureCell(post: post)//setting UI elements to data
            return cell
        } else {
            return PostCell()
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MINA: ID removed from Keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: SEGUE_IDENTIFIER1, sender: nil)
    }
    
    
}
