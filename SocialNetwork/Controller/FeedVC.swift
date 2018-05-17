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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var profileImg: UIImageView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var profilePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    var imageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        profilePicker = UIImagePickerController()
        profilePicker.allowsEditing = true
        profilePicker.delegate = self
        
        
        
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
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)//setting UI elements to data
            }
            
            return cell
            
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if imageCount == 1 {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                imageAdd.image = image
                imageSelected = true
                imageCount = 0
            } else {
                print("MINA: A valid image was not selected")
                imageCount = 0
            }
            imagePicker.dismiss(animated: true, completion: nil)
        
        }
       
            //profileImage below ---------------------
        if imageCount == 2 {
            if let profilePic = info[UIImagePickerControllerEditedImage] as? UIImage {
                profileImg.image = profilePic
                imageSelected = true
                saveUploadProfilePicToFB(img: profilePic)
                imageCount = 0
            } else {
            print("MINA: A valid profileimage was not selected")
            imageCount = 0
            }
            profilePicker.dismiss(animated: true, completion: nil)
        }
        
    }
    

    
    @IBAction func profileImgTapped(_ sender: Any) {
        imageCount = 2
        present(profilePicker, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        
        imageCount = 1
        present(imagePicker, animated: true, completion: nil)
        
    }

    @IBAction func postButtonTapped(_ sender: Any) {
        
        guard let caption = captionField.text, caption != "" else {
            print("MINA: Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {// check to see if the img has an image
            print("MINA: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString//gets us the UID of the post
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metaData){ (metaData, error)in
                if error != nil {
                    print("MINA: Unable to upload image to Firebase Storage")
                } else {
                    print("MINA: Successfully uploaded to Firebase Storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                        print("MINA: Successfully uploaded to Firebase Database")
                    }
                }
            }
        }
        
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    
    func saveUploadProfilePicToFB(img: UIImage) {
        //upload chosen image to firebase
        if let profImgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString//generates unique ID for image
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).putData(profImgData, metadata: metaData) { (metaData, error) in
                
                if error != nil {
                    print("MINA: Unable to upload Profile pic to firebase storage")
                } else {
                    print("MINA: Successfully uploaded image to Firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    UserDefaults.standard.set(downloadURL, forKey: "savedImage")
                    
                    print("MINA: \(String(describing: downloadURL))")
                }
                
            }
        }
    }
    
    func getProfilePic() {
        //get from NSUserdafaults or Firebase
        
        
        
    }

    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MINA: ID removed from Keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: SEGUE_IDENTIFIER1, sender: nil)
    }
    
    
}
