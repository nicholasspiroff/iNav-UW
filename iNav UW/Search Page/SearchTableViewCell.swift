//
//  SearchTableViewCell.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/5/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var circleView: DesignableView!
    @IBOutlet weak private var mainLabel: UILabel!
    @IBOutlet weak private var subLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setIcon(to icon: UIImage) {
        iconImageView.image = icon
    }

    func setCircleColor(to color: UIColor) {
        circleView.backgroundColor = color
    }
    
    func setMainTitle(to title: String) {
        mainLabel.text = title
        
        if mainLabel.attributedText != nil {
            let attStr = NSMutableAttributedString(string: title, attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ])
            
            mainLabel.attributedText = attStr
        }
    }
    
    func filterTitle(withRange range: Range<String.Index>) {
        guard let title = mainLabel.text else { return }
        
        let attStr = NSMutableAttributedString(string: title, attributes: [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 24)
        ])
        
        attStr.addAttribute(NSAttributedStringKey.foregroundColor,
                            value: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5),
                            range: NSMakeRange(0, attStr.length))
        
        attStr.addAttribute(NSAttributedStringKey.foregroundColor,
                            value: UIColor.white,
                            range: NSMakeRange(title.distance(from: title.startIndex, to: range.lowerBound), title.distance(from: range.lowerBound, to: range.upperBound)))
        
        mainLabel.attributedText = attStr
    }
    
    func setSubtitle(to title: String) {
        subLabel.text = title
    }
}
