//
//  UIViewExtensions.swift
//  CheerUp
//
//  Created by stefan on 13/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Foundation

extension UIView{
    
    ///adds a blur effect to the view
    public func addBlurEffect(){
        let blurEffect = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(effectView)
    }
}
