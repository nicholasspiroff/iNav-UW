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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCircleColor(to color: UIColor) {
        circleView.backgroundColor = color
    }
    
    func setMainTitle(to title: String) {
        mainLabel.text = title
    }
    
    func setSubtitle(to title: String) {
        subLabel.text = title
    }
}
