//
//  CustomItems.swift
//  PrenotaUnCampo
//
//  Created by Stefano Demattè on 02/11/2018.
//  Copyright © 2018 StefanoDemattè. All rights reserved.
//

import Foundation
import UIKit

let radius : CGFloat = 3.0

class FieldCustom: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = radius
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.4
//        self.layer.shadowRadius = radius
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
}



