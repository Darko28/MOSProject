//
//  DJIAircraftAnnotationView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit


//let kCalloutWidth: CGFloat = 200.0
//let kCalloutHeight: CGFloat = 70.0


class DJIAircraftAnnotationView: MAAnnotationView, MAMapViewDelegate {
    
    var aircraftImageView: UIImageView!
    var calloutView: CustomWaypointCalloutView?

    var rotateDegree: CGFloat {
        set {
            self.aircraftImageView.transform = CGAffineTransform(rotationAngle: newValue)
        }
        get {
            return self.rotateDegree
        }
    }
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isEnabled = false
        self.isDraggable = false
        self.aircraftImageView = UIImageView()
        self.addSubview(aircraftImageView)
        self.rotateDegree = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage!) {
        self.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        self.aircraftImageView.image = image
        self.aircraftImageView.sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected == selected {
            return
        }
        if selected {
            if self.calloutView == nil {
                self.calloutView = CustomWaypointCalloutView.init(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
                self.calloutView?.center = CGPoint(x: self.bounds.width / 2 + self.calloutOffset.x, y: -((self.calloutView?.bounds.height)! / 2 + self.calloutOffset.y))
            }
//            self.calloutView?.image = UIImage(named: "calloutIcon")
//            self.calloutView?.title = self.annotation.title
//            self.calloutView?.subTitle = self.annotation.subtitle
            self.calloutView?.setImage(image: UIImage(named: "calloutIcon")!)
            self.calloutView?.setTitle(title: self.annotation.title!)
            self.calloutView?.setSubTitle(subTitle: self.annotation.subtitle!)
            
            self.addSubview(self.calloutView!)
        } else {
            self.calloutView?.removeFromSuperview()
        }
        
        super.setSelected(selected, animated: animated)
    }

}
