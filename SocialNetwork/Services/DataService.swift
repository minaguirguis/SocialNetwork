//
//  DataService.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 4/21/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()//this will contain the URL of the root of our databse
let STORAGE_BASE = Storage.storage().reference()//Accessing the storage from Firebase with this

class DataService {
    
    static let ds = DataService()//created singleton
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child(POSTS_REF)//getting the object posts
    private var _REF_USERS = DB_BASE.child(USERS_REF)
    
    //Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child(POST_STORAGE_REF)
    //file the same way for profile images
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_POST_IMAGES: StorageReference {
        return _REF_POST_IMAGES
    }
    
    
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
        //its referencing users and creating a uid if one is not found
        print("MINA: Successfully created user in Firebase")
    }

    
    
}
