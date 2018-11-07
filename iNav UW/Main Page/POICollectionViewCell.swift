//
//  POICollectionViewCell.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/2/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

class POICollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var circleView: UIView!
    @IBOutlet weak private var title: UILabel!
    @IBOutlet weak private var iconView: UIImageView!
    
    override func draw(_ rect: CGRect) {
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    func setTitle(to title: String) {
        self.title.text = title
    }
    
    func setIcon(toImageNamed imageName: String) {
        if let image = UIImage(named: imageName) {
            iconView.image = image
        }
        else {
            let placeholder = "no title"
            print("Failed to load image for POI cell: \(title.text ?? placeholder)")
        }
    }
    
    func setBackgroundColor(to color: UIColor) {
        circleView.backgroundColor = color
    }
}
