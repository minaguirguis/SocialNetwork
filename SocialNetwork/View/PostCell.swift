//
//  PostCell.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 4/20/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) { //at this point the image is in the cache not a URL
        
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child(LIKES_REF).child(post.postKey)
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        if img != nil { //if the cache has an image then set it, if not then download it
            self.postImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("MINA: Unable to download image from Firebase storage")
                } else {
                    print("MINA: Image downloaded from Firebase storage")
                    if let imageData = data {
                        if let img = UIImage(data: imageData){
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            print("MINA: Image Set in Cache")
                        }
                    }
                }
                
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
    }
    
    @objc func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)//adding this to the user's likes
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()//removing like from user's likes
            }
        })
    }
    

}
