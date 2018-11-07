//
//  UIViewController+BlurEffects.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/2/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addDarkBlurBackground(toView view: UIView) {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let effectView = UIVisualEffectView(effect: blurEffect)
            view.insertSubview(effectView, at: 0)
            effectView.layer.cornerRadius = Constants.cornerRadius
            effectView.layer.masksToBounds = true
            effectView.frame = view.bounds
            effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
}
