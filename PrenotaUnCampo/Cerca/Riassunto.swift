//
//  Riassunto.swift
//  PrenotaUnCampo
//
//  Created by Stefano Demattè on 03/11/2018.
//  Copyright © 2018 StefanoDemattè. All rights reserved.
//
import UIKit
import Foundation

class Riassunto: UIViewController {
    
    @IBOutlet var iconMarker: UIImageView!
    @IBOutlet var iconSearch: UIImageView!
    @IBOutlet var iconWatch: UIImageView!

    @IBOutlet var labelDove: UILabel!
    @IBOutlet var labelCosa: UILabel!
    @IBOutlet var labelQuando: UILabel!
    
    let myYellowColor = UIColor(red: 255/255, green: 202/255, blue: 9/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        iconMarker.image = iconMarker.image!.withRenderingMode(.alwaysTemplate)
        iconMarker.tintColor = myYellowColor
        iconSearch.image = iconSearch.image!.withRenderingMode(.alwaysTemplate)
        iconSearch.tintColor = myYellowColor
        iconWatch.image = iconWatch.image!.withRenderingMode(.alwaysTemplate)
        iconWatch.tintColor = myYellowColor
        
        self.labelDove.text = "Lat:" + UserDefaults.standard.string(forKey: "myLatitude")! + "\nLon:" + UserDefaults.standard.string(forKey: "myLongitude")!
        self.labelCosa.text = UserDefaults.standard.string(forKey: "myCosa")!
        self.labelQuando.text = UserDefaults.standard.string(forKey: "myQuando")!

    }
}
