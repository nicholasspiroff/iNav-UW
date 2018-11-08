//
//  SectionTitleTableViewCell.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/7/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        separatorInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.width, 0, 0)
    }

    func setTitle(to title: String) {
        titleLabel.text = title.uppercased()
    }

}
