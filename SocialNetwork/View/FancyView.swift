//
//  FancyView.swift
//  SocialNetwork
//
//  Created by Mina Guirguis on 3/31/18.
//  Copyright © 2018 Mina Guirguis. All rights reserved.
//

import UIKit

class FancyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
            layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor//alpha determines how light the color
            layer.shadowOpacity = 0.8//how dark shadow is
            layer.shadowRadius = 5.0//how far shadow spans out
            layer.shadowOffset = CGSize(width: 1.0, height: 1.0)//the blur radius used to create the shadow
            layer.cornerRadius = 2.0
            
    }

}
