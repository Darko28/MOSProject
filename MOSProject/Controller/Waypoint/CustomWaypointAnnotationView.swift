//
//  CustomWaypointAnnotationView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/30.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit


let kCalloutWidth: CGFloat = 180.0
let kCalloutHeight: CGFloat = 64.0

class CustomWaypointAnnotationView: MAAnnotationView {
    
    var calloutView: CustomWaypointCalloutView?

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("selected")
        if self.isSelected == selected {
            return
        }
        if selected {
            if self.calloutView == nil {
                self.calloutView = CustomWaypointCalloutView.init(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
                self.calloutView?.center = CGPoint(x: self.bounds.width / 2 + self.calloutOffset.x, y: -((self.calloutView?.bounds.height)! / 2 + self.calloutOffset.y))
            }
            self.calloutView?.setImage(image: UIImage(named: "calloutIcon")!)
            self.calloutView?.setTitle(title: self.annotation.title!)
            self.calloutView?.setSubTitle(subTitle: self.annotation.subtitle!)
            
            self.addSubview(self.calloutView!)
        } else {
            self.calloutView?.removeFromSuperview()
        }
        
        super.setSelected(selected, animated: animated)
    }
        
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
