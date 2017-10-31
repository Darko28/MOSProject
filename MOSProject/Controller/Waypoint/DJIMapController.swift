//
//  DJIMapController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class DJIMapController: NSObject {

    public var editPoints: Array<CLLocation> = []
    var aircraftAnnotation: DJIAircraftAnnotation? = nil
    public var pointList: Array<CLLocationCoordinate2D> = []
        
    func wayPoints() -> [CLLocation] {
        return self.editPoints
    }
    
    func addPoint(_ point: CGPoint, withMapView mapView: MAMapView) {
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        editPoints.append(location)
        pointList.append(location.coordinate)
        let annotation: MAPointAnnotation = MAPointAnnotation()
        annotation.title = "waypoint pm2.5"
        annotation.subtitle = "waypoint pm10"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func clearAllPointsInMapView(_ mapView: MAMapView) {
        editPoints.removeAll()
        var annos = mapView.annotations
        for i in 0 ..< annos!.count {
            let anno = annos![i]
            if !((anno as AnyObject).isEqual(self.aircraftAnnotation)) {
                mapView.removeAnnotation(anno as! MAAnnotation)
            }
        }
    }
    
    func updateAircraftLocation(_ location: CLLocationCoordinate2D, withMapView mapView: MAMapView) {
        if self.aircraftAnnotation == nil {
            print("aircraftAnnotation is nil, create an DJIAircraftAnnotation")
            
            self.aircraftAnnotation = DJIAircraftAnnotation(coordinate: location)
            self.aircraftAnnotation?.title = "aircraft pm2.5"
            self.aircraftAnnotation?.subtitle = "aircraft pm10"
            mapView.addAnnotation(self.aircraftAnnotation)
        }
        self.aircraftAnnotation!.setCoordinate(location)
    }
    
}
