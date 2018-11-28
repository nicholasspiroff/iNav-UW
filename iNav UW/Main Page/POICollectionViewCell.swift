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
    @IBOutlet weak private var iconWidth: NSLayoutConstraint!
    @IBOutlet weak private var iconHeight: NSLayoutConstraint!
    
    let sqrt2 = sqrt(2)
    
    override func draw(_ rect: CGRect) {
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    func setTitle(to title: String) {
        self.title.text = title
    }
    
    func setIcon(to image: UIImage) {
        let sideLength = (circleView.frame.width / 2) / CGFloat(sqrt2)
        iconWidth.constant = sideLength
        iconHeight.constant = sideLength
        
        iconView.image = image
    }
    
    func setBackgroundColor(to color: UIColor) {
        circleView.backgroundColor = color
    }
}
