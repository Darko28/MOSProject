//
//  DJIAircraftAnnotationView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class DJIAircraftAnnotationView: MAAnnotationView, MAMapViewDelegate {
    
    var aircraftAnno: DJIAircraftAnnotation?
    
    var aircraftImageView: UIImageView!
    
    var rotateDegree: CGFloat {
        set {
            self.aircraftImageView.transform = CGAffineTransform(rotationAngle: newValue)
            rotate1 = newValue
        }
        get {
            return self.rotateDegree
        }
    }
    
    var rotate1: CGFloat = 0.0
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isEnabled = false
        self.isDraggable = false
//        self.image = UIImage(named: "aircraft.png")
        self.aircraftImageView = UIImageView()
        self.addSubview(aircraftImageView)
        self.rotateDegree = 0
        
//        if self.annotation != nil {
//            print("\(rotate1)")
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeading(_ heading: CGFloat) {
//        print("DJIAircraftAnnotationView update heading")
//        self.transform = CGAffineTransform.identity
//        self.transform = CGAffineTransform(rotationAngle: heading)
//        (self.annotation as! DJIAircraftAnnotation).rotateDegree()
        self.rotateDegree = heading
        if self.annotation != nil {
            print("\(self.rotate1)")
        }

    }
    
    func updateImage(image: UIImage!) {
        self.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        self.aircraftImageView.image = image
        self.aircraftImageView.sizeToFit()
    }
    
//    func updateHeading(_ heading: CGFloat, withAnnotations annotations: MAAnimatedAnnotation, count: UInt) {
//        self.annotation = annotation
//        annotation.addMoveAnimation(withKeyCoordinates: &(annotation.coordinate), count: count, withDuration: 5, withName: nil, completeCallback: nil)
//    }
    
}
