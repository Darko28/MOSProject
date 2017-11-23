//
//  AnimatedAnnotationViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/25.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit


class MovingAnnotationViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var aircraftAnnotation: MAAnimatedAnnotation!
    var coords1: Array<CLLocationCoordinate2D> = []
    var coords2: Array<CLLocationCoordinate2D> = []
    var coords3: Array<CLLocationCoordinate2D> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initCoordinates()
        
        self.mapView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleHeight.rawValue) | UInt8(UIViewAutoresizing.flexibleWidth.rawValue)))
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        self.aircraftAnnotation = MAAnimatedAnnotation.init()
        self.aircraftAnnotation.coordinate = self.coords1.first!
        self.mapView.addAnnotation(self.aircraftAnnotation)
        
        // add overlay
        let polyline1: MAPolyline! = MAPolyline.init(coordinates: &(self.coords1), count: UInt(self.coords1.count))
        
        self.mapView.addOverlays([polyline1])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCoordinates() {
        coords1.append(CLLocationCoordinate2D.init(latitude: 2, longitude: 2))
        coords1.append(CLLocationCoordinate2D.init(latitude: 2, longitude: 2))
        coords1.append(CLLocationCoordinate2D.init(latitude: 2, longitude: 2))
        coords1.append(CLLocationCoordinate2D.init(latitude: 2, longitude: 2))
    }
    
    func generateStarPoints(center: CLLocationCoordinate2D) {
        let STAR_RADIUS = 0.05
        let PI = 3.1415926
        let starRaysCount = 5
        var i = 0
        
        while i < starRaysCount {
            var angle = 2.0 * Double.init(i) / Double(starRaysCount) * PI
            var index = 2 * i
            coords3.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS * sin(angle) + center.latitude, longitude: STAR_RADIUS * cos(angle) + center.longitude))
            
            index += 1
            angle = angle + 1.0/Double(starRaysCount) * PI
            
            coords3.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS/2.0 * sin(angle) + center.latitude, longitude: STAR_RADIUS/2.0 * cos(angle) + center.longitude))
            
            i += 1
        }
    }
    
    func start() {
        self.aircraftAnnotation.coordinate = coords1[0]
        self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.coords1), count: UInt(self.coords1.count), withDuration: 5, withName: nil, completeCallback: nil)
        self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.coords3), count: UInt(self.coords2.count), withDuration: 5, withName: nil, completeCallback: nil)
    }
    
    func stop() {
        if self.aircraftAnnotation.allMoveAnimations() == nil {
            return
        }
        for item in self.aircraftAnnotation.allMoveAnimations() {
            let animation = item
            animation.cancel()
        }
        self.aircraftAnnotation.movingDirection = 0
        self.aircraftAnnotation.coordinate = coords1[0]
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIdentifier = "myReuseIdentifier"
            var annotationView: MAPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier) as! MAPinAnnotationView!
            if annotation == nil {
                annotationView = MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
                let img = UIImage(named: "aircraft")
                annotationView.image = img
            }
            
            annotationView.animatesDrop = false
            annotationView.isDraggable = false
            
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let polylineRenderer = MAPolylineRenderer(polyline: overlay as! MAPolyline!)
            polylineRenderer?.lineWidth = 8.0
            polylineRenderer?.strokeImage = UIImage(named: "arrow")
            return polylineRenderer
        }
        return nil
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

