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
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(post: Post, img: UIImage? = nil) { //at this point the image is in the cache not a URL
        
        self.post = post
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
        
    }
    

}
