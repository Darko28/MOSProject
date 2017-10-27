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
    var mapVC: DJIMapController = DJIMapController()
    
    var annotationView: DJIAircraftAnnotationView?
    
    var _coordinate: CLLocationCoordinate2D
    @objc dynamic override var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set {
            _coordinate = newValue
        }
    }
    
    func initAnnotationView() {
        self.annotationView = DJIAircraftAnnotationView.init(annotation: mapVC.aircraftAnnotation, reuseIdentifier: "Aircraft_Annotation")
        self.annotationView!.annotation = mapVC.aircraftAnnotation
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        _coordinate = coordinate
        super.init()
    }
    
    func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func updateHeading(_ heading: CGFloat) {
        
        self.initAnnotationView()
        
        if self.annotationView != nil {
            self.annotationView!.updateHeading(heading)
        } else {
            print("nil")
        }
//        return heading
    }
    
//    override func rotateDegree() -> CLLocationDirection {
//        if rootVC.aircraftState != nil {
//            return (rootVC.aircraftState!.attitude.yaw * .pi) / 180.0
//        }
//        return 0
//    }
    
}
