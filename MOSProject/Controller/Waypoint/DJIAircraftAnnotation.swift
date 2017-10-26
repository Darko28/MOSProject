//
//  DJIAircraftAnnotation.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit


class DJIAircraftAnnotation: MAAnimatedAnnotation {
    
    var rootVC: DJIRootViewController = DJIRootViewController()
    
    var annotationView: DJIAircraftAnnotationView?
    
//    var coordinate: CLLocationCoordinate2D
    
    var _coordinate: CLLocationCoordinate2D
    @objc dynamic override var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set {
            _coordinate = newValue
        }
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        _coordinate = coordinate
        super.init()
    }
    
    func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func updateHeading(_ heading: CGFloat) -> CGFloat {
//        self.annotationView!.updateHeading(heading)
        return heading
    }
    
//    override func rotateDegree() -> CLLocationDirection {
//        if rootVC.aircraftState != nil {
//            return (rootVC.aircraftState!.attitude.yaw * .pi) / 180.0
//        }
//        return 0
//    }
    
}
