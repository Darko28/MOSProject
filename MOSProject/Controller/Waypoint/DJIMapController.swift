//
//  DJIMapController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class DJIMapController: UIViewController {

    public var editPoints: Array<CLLocation> = []
    var aircraftAnnotation: DJIAircraftAnnotation? = nil
    public var pointList: Array<CLLocationCoordinate2D> = []
        
    func wayPoints() -> [CLLocation] {
        return self.editPoints
    }
    
    func addPoint(_ point: CGPoint, withMapView mapView: MAMapView) {
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
//        let amapCoordinate: CLLocationCoordinate2D = AMapCoordinateConvert(coordinate, .GPS)
        let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        editPoints.append(location)
        pointList.append(location.coordinate)
        let annotation: MAPointAnnotation = MAPointAnnotation()
        annotation.title = "waypoint pm2.5"
        annotation.subtitle = "waypoint pm10"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func createWaypoint(waypointCoordinate: CLLocationCoordinate2D, with zeroHorizontalVelocity: Double, with mapView: MAMapView) {
        if zeroHorizontalVelocity != 0 {
            print("horizontal velocity is not 0")
            let alertController = UIAlertController(title: "Set waypoints error!", message: "Horizontal velocity is not zero!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        } else {
            let alertController = UIAlertController(title: "Set waypoints", message: "setting waypoint", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            let waypointLocation: CLLocation = CLLocation(latitude: waypointCoordinate.latitude, longitude: waypointCoordinate.longitude)
            self.editPoints.append(waypointLocation)
            
            let amapLocation = AMapCoordinateConvert(waypointLocation.coordinate, .GPS)
            
            let annotation: MAPointAnnotation = MAPointAnnotation()
            annotation.title = "create waypoint pm2.5"
            annotation.subtitle = "create waypoint pm10"
            annotation.coordinate = amapLocation
            mapView.addAnnotation(annotation)
        }
    }
    
    func uploadCoordinates(waypointCoordinate: CLLocationCoordinate2D, with mapView: MAMapView) {
//        if CLLocationCoordinate2DIsValid(waypointCoordinate) {
            let waypointLocation: CLLocation = CLLocation(latitude: waypointCoordinate.latitude, longitude: waypointCoordinate.longitude)
            self.editPoints.append(waypointLocation)
            
            let amapLocation = AMapCoordinateConvert(waypointLocation.coordinate, .GPS)
            
            let annotation: MAPointAnnotation = MAPointAnnotation()
            annotation.title = "create waypoint using coordinate"
            annotation.subtitle = "waypoint using coordinate"
            annotation.coordinate = amapLocation
            mapView.addAnnotation(annotation)
//        } else {
//            let alertController = UIAlertController(title: "Upload waypoints", message: "upload coordinate is invalid", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alertController, animated: true, completion: nil)
//        }
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
                
                let amapLocation = AMapCoordinateConvert(location, .GPS)
                
                self.aircraftAnnotation = DJIAircraftAnnotation(coordinate: amapLocation)
                self.aircraftAnnotation?.title = "aircraft pm2.5"
                self.aircraftAnnotation?.subtitle = "aircraft pm10"
                mapView.addAnnotation(self.aircraftAnnotation)
            }
            self.aircraftAnnotation!.setCoordinate(location)
    }
    
}
