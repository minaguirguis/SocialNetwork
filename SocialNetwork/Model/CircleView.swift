//
//  CircleView.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 4/20/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        //super.draw(rect)
        layer.cornerRadius = self.frame.width / 2
        //clipsToBounds = true
    }
    
}
