//
//  DJIRootViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK

class DJIRootViewController: UIViewController, MAMapViewDelegate, CLLocationManagerDelegate, DJIGSButtonControllerDelegate, DJIFlightControllerDelegate, DJIWaypointConfigViewControllerDelegate, DJISDKManagerDelegate {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    
    var createWaypointButton: UIButton!
    
    
    var mapView: MAMapView!
    
    var mapController: DJIMapController?
    var tapGesture: UITapGestureRecognizer?
    var gsButtonVC: DJIGSButtonController?
    var waypointConfigVC: DJIWaypointConfigViewController?
    
    var isEditingPoints = false
    
    var locationManager: CLLocationManager = CLLocationManager()
    var droneLocation: CLLocationCoordinate2D?
    var userLocation: CLLocationCoordinate2D? = kCLLocationCoordinate2DInvalid
    
    var waypointMission: DJIMutableWaypointMission?
    
    var missionOperator: DJIWaypointMissionOperator? = {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }()
    
    var waypointCoordinates: Array<CLLocationCoordinate2D> = []
    var waypointTrace: MAPolyline?
    
    var distanceArray = [Double]()
    var sumDistance: Double = 0.0

    var passedCoordinatesCount: Int = 0
    var passedTrajectory: MAPolyline!
    
    var coordinatesBuffer: Array<CLLocationCoordinate2D> = []
    
    var cancelTapGesture: UITapGestureRecognizer? = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
    
    var aircraftStatus: DJIFlightControllerState?

    var homeLocation: CLLocationCoordinate2D?
    
    var fc: DJIFlightController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerApp()
        self.initUI()
        self.initData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardUp(_ notification: Notification) {
        
        if let userInfo = notification.userInfo, let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue, let _ = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double, let _ = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            
            let frame = value.cgRectValue
            let intersection = frame.intersection(self.waypointConfigVC!.view.frame)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.waypointConfigVC?.view.transform = CGAffineTransform(translationX: 0, y: -intersection.height)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            self.focusMap()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func registerApp() {
        DJISDKManager.registerApp(with: self)
        AMapServices.shared().apiKey = "f955eac006cdd6c13404478556ba7701"
        AMapServices.shared().enableHTTPS = true
    }
    
    func initUI() {
        
        self.modeLabel?.text = "N/A"
        self.gpsLabel?.text = "0"
        self.hsLabel?.text = "0.0 M/S"
        self.vsLabel?.text = "0.0 M/S"
        self.altitudeLabel?.text = "0 M"
        
        self.mapView = MAMapView(frame: self.view.bounds)
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .none
        
        self.gsButtonVC = DJIGSButtonController(nibName: "DJIGSButtonController", bundle: Bundle.main)
        if self.gsButtonVC != nil {
            self.gsButtonVC?.view.frame = CGRect(x: 10, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 72), width: self.gsButtonVC!.view.frame.size.width, height: self.gsButtonVC!.view.frame.size.height)
        } else {
            print("gsButtonVC is nil")
        }
        self.gsButtonVC!.delegate = self
        
        self.view.addSubview(mapView)
        self.view.addSubview(topView)
        self.view.addSubview(gsButtonVC!.view)
        
        self.waypointConfigVC = DJIWaypointConfigViewController(nibName: "DJIWaypointConfigViewController", bundle: Bundle.main)
        self.waypointConfigVC?.view.alpha = 0
        self.waypointConfigVC?.view.autoresizingMask = UIViewAutoresizing(rawValue: (UIViewAutoresizing.flexibleLeftMargin.rawValue)|(UIViewAutoresizing.flexibleRightMargin.rawValue)|(UIViewAutoresizing.flexibleTopMargin.rawValue)|(UIViewAutoresizing.flexibleBottomMargin.rawValue))
//        let configVCOriginX = (self.view.frame.width - (self.waypointConfigVC?.view.frame.width)!) / 2
//        let configVCOriginY = self.topView.frame.height + self.topView.frame.minY + 8
//        self.waypointConfigVC?.view.frame = CGRect(x: configVCOriginX, y: CGFloat(configVCOriginY), width: (self.waypointConfigVC?.view.frame.width)!, height: (self.waypointConfigVC?.view.frame.height)!)
//        if UIDevice.current.userInterfaceIdiom == .pad {
            self.waypointConfigVC?.view.center = self.view.center
//        }
        
        self.waypointConfigVC?.delegate = self
        self.view.addSubview((self.waypointConfigVC?.view)!)
        
//        self.mapView.addAnnotation(self.aircraftAnnotation)
        
        self.mapView.isUserInteractionEnabled = true
        
        self.createWaypointButton = UIButton(frame: CGRect(x: 20, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 300), width: 100, height: 48))
        self.createWaypointButton.backgroundColor = UIColor.lightGray
        self.createWaypointButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.createWaypointButton.titleLabel?.textColor = UIColor.white
        self.createWaypointButton.setTitle("create waypoint", for: .normal)
        self.createWaypointButton.addTarget(self, action: #selector(createWaypoints(_:)), for: .touchUpInside)
        self.mapView.addSubview(self.createWaypointButton)
    }
    
    func initData() {
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.mapController = DJIMapController()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWaypoints(_:)))
        self.cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
//        self.mapView.addGestureRecognizer(self.tapGesture!)
    }
    
    func appRegisteredWithError(_ error: Error?) {
        if error != nil {
            print("DJI SDK register failed!")
            let alertController = UIAlertController(title: "DJISDK Register", message: "\(error!.localizedDescription)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            print("DJI SDK register succeed!")
            DJISDKManager.enableBridgeMode(withBridgeAppIP: "192.168.1.101")
            self.appDelegate?.model?.addLog(newLogEntry: "waypoint registration succeed")
            DJISDKManager.startConnectionToProduct()
        }
    }
//
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            let flightController = (DJISDKManager.product() as? DJIAircraft)?.flightController
            flightController?.delegate = self
            self.appDelegate?.model?.addLog(newLogEntry: "waypoint product is connected")
            DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
                if error != nil {
                    self.appDelegate?.model?.addLog(newLogEntry: "Login failed")
                    print("Login failed")
                }
            }
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "product is nil")
        }
    }
    
    var homeAnnotation: MAPointAnnotation?
    
    func focusMap() {
        self.appDelegate?.model?.addLog(newLogEntry: "\(String(describing: self.droneLocation))")
//        if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            var region: MACoordinateRegion = MACoordinateRegion()
            if self.homeLocation != nil {
                self.homeAnnotation = MAPointAnnotation()
                homeAnnotation?.coordinate = self.homeLocation!
                mapView.addAnnotation(self.homeAnnotation)
//                region.center = AMapCoordinateConvert(self.droneLocation!, .GPS)
                region.center = self.homeLocation!
                region.span.latitudeDelta = 0.001
                region.span.longitudeDelta = 0.001
                mapView.setRegion(region, animated: true)
                
                if self.homeLocale != nil {
                    fc?.setHomeLocation(self.homeLocale!, withCompletion: nil)
                } else {
                    self.appDelegate?.model?.addLog(newLogEntry: "homeLocation using aircraft current location")
                    fc?.setHomeLocationUsingAircraftCurrentLocationWithCompletion(nil)
                }

            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "drone location nil")
                print("location nil")
            }
    }
    
    @objc func singleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        print("single tap")
        if !self.isEditingPoints {
            if self.waypointConfigVC != nil {
                //                self.waypointConfigVC!.view.isFirstResponder ? (self.waypointConfigVC?.singleTap.isEnabled = true) : (self.waypointConfigVC?.singleTap.isEnabled = false)
                if (self.waypointConfigVC?.singleTap.isEnabled)! || (self.waypointConfigVC?.view.isFirstResponder)! {
                    self.waypointConfigVC?.singleTap.isEnabled = false
                    print("keyboard resign first responder")
                    self.waypointConfigVC?.cancelKeyboard((waypointConfigVC?.singleTap)!)
                } else {
                    print("hide waypoint config view")
                    self.waypointConfigVC?.view.alpha = 0
                    self.waypointConfigVC?.singleTap.isEnabled = true
                }
            }
        }
    }
    
    @objc func cancelKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        self.mapView.endEditing(true)
    }
    
    @objc func addWaypoints(_ tapGesture: UITapGestureRecognizer) {
        let point: CGPoint = tapGesture.location(in: self.mapView)
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.appDelegate?.model?.addLog(newLogEntry: "add point")
                print("add points")
                self.mapController?.addPoint(point, withMapView: self.mapView)
                if mapController?.editPoints.count != 0 {
                    for coord in (self.mapController?.editPoints)! {
                        aircraftCoords.append(coord.coordinate)
                    }
                }
            } else {
                print("isEditingPoints is false")
            }
        }
    }
    
    @objc func createWaypoints(_ sender: UIButton) {
        print("create waypoint")
        self.appDelegate?.model?.addLog(newLogEntry: "create waypoint")
        if self.aircraftStatus?.aircraftLocation?.coordinate != nil {
            let aircraftCoordinate: CLLocationCoordinate2D = (self.aircraftStatus?.aircraftLocation?.coordinate)!
            let horizontalVelocity = (self.aircraftStatus?.velocityX == 0 && self.aircraftStatus?.velocityY == 0) ? 0.0 : 1.0
            
            self.mapController?.createWaypoint(waypointCoordinate: aircraftCoordinate, with: horizontalVelocity, with: self.mapView)
        }
    }
    
    func addBtn(button: UIButton, withActionInGSButtonVC GSBtnVC: DJIGSButtonController) {
        if self.isEditingPoints {
            self.mapView.removeGestureRecognizer(tapGesture!)
            self.isEditingPoints = false
            //            self.tapGesture?.isEnabled = false
            button.setTitle("Add", for: UIControlState.normal)
            self.coordinatesList()
        } else {
            self.view.removeGestureRecognizer(cancelTapGesture!)
            self.mapView.addGestureRecognizer(tapGesture!)
            self.isEditingPoints = true
//            self.tapGesture?.isEnabled = true
//            if self.mapView.gestureRecognizers!.contains(cancelTapGesture) {
//                print("add remove cancel gesture")
//                self.mapView.removeGestureRecognizer(cancelTapGesture)
//                self.waypointConfigVC?.singleTap.isEnabled = false
//            }
            button.setTitle("Finished", for: UIControlState.normal)
        }
    }
    
    func focusMapBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        self.focusMap()
    }
    
    func switchToMode(_ mode: DJIGSViewMode, inGSButtonVC gsbtnVC: DJIGSButtonController) {
        if mode == DJIGSViewMode.EditMode {
            self.focusMap()
        }
    }
    
    func clearBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
//        self.mapController?.clearAllPointsInMapView(self.mapView)
        if self.passedTrajectory != nil {
            self.appDelegate?.model?.addLog(newLogEntry: "remove passed trajectory")
            //            let trajectoryCount = self.coordinatesBuffer.count
            //            for _ in 0..<trajectoryCount {
            //                self.mapView.remove(self.passedTrajectory)
            self.clearAllTrajectoryInMapView(mapView: self.mapView)
            self.mapView.remove(self.passedTrajectory)
            self.coordinatesBuffer.removeAll()
            //            }
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "passedTrajectory is nil")
        }
    }
    
    func clearRoutesBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        if self.passedTrajectory != nil {
            self.appDelegate?.model?.addLog(newLogEntry: "remove passed trajectory")
            //            let trajectoryCount = self.coordinatesBuffer.count
            //            for _ in 0..<trajectoryCount {
            //                self.mapView.remove(self.passedTrajectory)
            self.clearAllTrajectoryInMapView(mapView: self.mapView)
            self.mapView.remove(self.passedTrajectory)
            self.coordinatesBuffer.removeAll()
            //            }
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "passedTrajectory is nil")
        }
    }
    
    func clearAllTrajectoryInMapView(mapView: MAMapView) {
        if self.passedTrajectory != nil {
            coordinatesBuffer.removeAll()
            var overlays = mapView.overlays
            for i in 0 ..< overlays!.count {
                let overlay = overlays![i]
                mapView.remove(overlay as! MAPolyline)
//                if !((overlay as AnyObject).isEqual(self.aircraftAnnotation)) {
//                    mapView.removeAnnotation(anno as! MAAnnotation)
//                }
            }
        }
    }
    
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        print("Start waypoint mission!")
        self.missionOperator?.startMission(completion: { (error) in
            if error != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "start waypoint mission failed with error: \(error!.localizedDescription)")
                print("start waypoint mission failed with error: \(error!.localizedDescription)")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "start waypoint mission succeeded!")
                print("start waypoint mission succeeded!")
            }
        })
    }
    
    func stopBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        print("stop waypoint mission")
        self.missionOperator?.stopMission(completion: { (error) in
            if error != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "stop waypoint mission failed with error: \(error!.localizedDescription)")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "stop waypoint mission succeed.")
            }
        })
    }
    
    func configBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        self.mapView.addGestureRecognizer(cancelTapGesture!)
        self.waypointConfigVC?.singleTap.isEnabled = false
        
        var waypoints = self.mapController?.wayPoints()
        if( waypoints == nil || (waypoints?.count)! < 2) {
            print("No or not enough waypoints for waypoint mission")
            return
        }
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.waypointConfigVC?.view.alpha = 1.0
        }
        
        if self.waypointMission != nil {
            self.waypointMission?.removeAllWaypoints()
        } else {
            self.waypointMission = DJIMutableWaypointMission()
        }
        
        for i in 0 ..< (waypoints?.count)! {
            let location: CLLocation? = waypoints?[i]
            if CLLocationCoordinate2DIsValid((location?.coordinate)!) {
//                let amapCoordinate: CLLocationCoordinate2D = AMapCoordinateConvert((location?.coordinate)!, .GPS)
                let waypoint: DJIWaypoint = DJIWaypoint(coordinate: (location?.coordinate)!)
                waypoint.cornerRadiusInMeters = 3.0
                self.waypointMission?.add(waypoint)
            }
        }
    }
    
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.waypointConfigVC?.view.alpha = 0
        }
        
        for i in 0 ..< Int((self.waypointMission?.waypointCount)!) {
            let waypoint: DJIWaypoint? = self.waypointMission?.waypoint(at: UInt(i))
            waypoint?.altitude = (self.waypointConfigVC?.altitudeTextfield.text)!._bridgeToObjectiveC().floatValue
        }
        
        self.waypointMission?.maxFlightSpeed = ((self.waypointConfigVC?.maxFlightSpeedTextField.text)! as NSString).floatValue
        self.waypointMission?.autoFlightSpeed = Float(CFStringGetDoubleValue((self.waypointConfigVC?.autoFlightSpeedTextField.text)! as CFString!))
        self.waypointMission?.headingMode = DJIWaypointMissionHeadingMode(rawValue: UInt((self.waypointConfigVC?.headingSegmentedControl.selectedSegmentIndex)!))!
        self.waypointMission?.finishedAction = DJIWaypointMissionFinishedAction(rawValue: UInt8((self.waypointConfigVC?.actionSegmentedControl.selectedSegmentIndex)!))!
        
        if self.missionOperator == nil {
            self.appDelegate?.model?.addLog(newLogEntry: "missionOperator is nil")
        }
        
        self.waypointMission?.flightPathMode = .curved
//        self.missionOperator?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error) in
//            if error != nil {
//                self.appDelegate?.model?.addLog(newLogEntry: "mission finished error: \(error!.localizedDescription)")
//            } else {
//                self.mapController?.editPoints.removeAll()
//                self.appDelegate?.model?.addLog(newLogEntry: "mission finished!")
//            }
//        })
        
        self.missionOperator?.load(self.waypointMission!)
        
        self.missionOperator?.uploadMission(completion: { (error) in
            if error != nil {
                print("Upload mission failed")
                self.appDelegate?.model?.addLog(newLogEntry: "Upload mission failed")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "upload mission succeed")
                print("Upload mission succeed!")
            }
        })
        
        self.missionOperator?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error) in
            if error != nil {
                print("Mission execution failed")
                self.appDelegate?.model?.addLog(newLogEntry: "mission execution failed")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "mission execution succeed")
//                self.appDelegate?.model?.addLog(newLogEntry: "\(self.missionTotalDistance())")
//                self.mapController?.editPoints.removeAll()
                print("Mission execution finished")
            }
        })
    }
    
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.waypointConfigVC?.view.alpha = 0
        }
    }
    
    var aircraftCoords: Array<CLLocationCoordinate2D> = []
    var aircraftAnnotation: MAAnimatedAnnotation! = MAAnimatedAnnotation()
    
    var aircrafAnnoView: DJIAircraftAnnotationView!
    
//    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
//
//        if annotation.isKind(of: DJIAircraftAnnotation.self) {
//            let aircraftReuseIdentifier = "Aircraft_Annotation"
//            print("aircraft annotation")
//
//            var aircraftView: MAAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: aircraftReuseIdentifier)
//            if aircraftView == nil {
//                aircraftView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: aircraftReuseIdentifier)
//            }
//            aircrafAnnoView = aircraftView as! DJIAircraftAnnotationView
//            aircrafAnnoView.updateImage(image: UIImage(named: "aircraft.png"))
//            return aircraftView
//        } else if (annotation.isKind(of: MAPointAnnotation.self)) {
//
//            print("point annotation")
//            let pointReuseIdentifier = "Pin_Annotation"
//            //            let pinView: MAPinAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
//            var annotationView: MAPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier) as! MAPinAnnotationView!
//            if annotationView == nil {
//                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
//                let img = UIImage(named: "anno.png")
//                annotationView.image = img
//            }
//            return annotationView
//        }
//        return nil
//    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: DJIAircraftAnnotation.self) {
            let aircraftReuseIdentifier = "Aircraft_Annotation"
            print("aircraft annotation")
            
            var aircraftView: MAAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: aircraftReuseIdentifier)
            if aircraftView == nil {
                aircraftView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: aircraftReuseIdentifier)
            }
            aircrafAnnoView = aircraftView as! DJIAircraftAnnotationView
            aircrafAnnoView.updateImage(image: UIImage(named: "aircraft.png"))
            aircrafAnnoView.canShowCallout = false
            return aircraftView
        } else if (annotation.isKind(of: MAPointAnnotation.self)) {
            
            print("point annotation")
            let pointReuseIdentifier = "Pin_Annotation"
            //            let pinView: MAPinAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            var annotationView: CustomWaypointAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier) as! CustomWaypointAnnotationView!
            if annotationView == nil {
                annotationView = CustomWaypointAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
                let img = UIImage(named: "anno.png")
                annotationView.image = img
//                annotation.title = "waypoint pm2.5"
//                annotation.subtitle = "waypoint pm10"
                annotationView.canShowCallout = false
//                annotationView.centerOffset = CGPoint(x: 0, y: -18)
            }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        self.userLocation = location.coordinate
        self.homeLocale = location
    }

    var homeLocale: CLLocation?
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        
        self.fc = fc
        
        self.aircraftStatus = state
        
        self.droneLocation = state.aircraftLocation?.coordinate
//        self.homeLocation = state.aircraftLocation?.coordinate
        self.homeLocation = AMapCoordinateConvert((state.aircraftLocation?.coordinate)!, .GPS)
        
//        if state.aircraftLocation?.coordinate != nil {
////            self.droneLocation = AMapCoordinateConvert((state.aircraftLocation?.coordinate)!, .GPS)
//
////            MATraceManager.sharedInstance().queryProcessedTrace(with: [MATraceLocation], type: , processingCallback: , finishCallback: , failedCallback: )
//
//        }
        
        if self.droneLocation != nil {
            self.droneLocation = AMapCoordinateConvert((state.aircraftLocation?.coordinate)!, .GPS)
            self.mapController!.updateAircraftLocation(self.droneLocation!, withMapView: self.mapView)
            let radianYaw = ((state.attitude.yaw) * .pi / 180.0)
            self.aircrafAnnoView?.rotateDegree = CGFloat(radianYaw)
//            if mapController?.editPoints.count == 0 {
//                self.aircraftAnnotation.coordinate = droneLocation!
//            }
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "aircraftLocation is nil")
        }
        
        self.modeLabel.text = state.flightModeString
        self.gpsLabel.text = String(format: "%d", state.satelliteCount)
        self.vsLabel.text = String(format: "%.1f M/S", state.velocityZ)
        self.hsLabel.text = NSString.localizedStringWithFormat("%0.1f M/S", sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)) as String
        self.altitudeLabel.text = String(format: "%.1f M", state.altitude)
        
        if self.missionOperator?.currentState == DJIWaypointMissionState.executing {
            if state.aircraftLocation != nil {
                //            buffer[passedCoordinatesCount] = state.aircraftLocation!.coordinate
                coordinatesBuffer.append(self.droneLocation!)
                self.passedCoordinatesCount = coordinatesBuffer.count
            }
            
            self.drawPassedTrace()
        }
    }
    
    func drawTrace() {
        self.waypointTrace = MAPolyline(coordinates: &(self.waypointCoordinates), count: UInt(self.waypointCoordinates.count))
        self.mapView.add(self.waypointTrace)
    }
    
    func drawPassedTrace() {
        if self.mapController?.editPoints.count != 0 {
            let bufferCount = self.coordinatesBuffer.count
            print("\(bufferCount)")
//            let buffer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: self.passedCoordinatesCount)
//            for i in 0..<self.passedCoordinatesCount {
//                buffer[i] = self.droneLocation!
//            }
//            buffer[self.passedCoordinatesCount+1] = (self.mapController?.editPoints.last)!.coordinate
            
            self.passedTrajectory = MAPolyline.init(coordinates: &(self.coordinatesBuffer), count: UInt(bufferCount))
            self.mapView.add(self.passedTrajectory)
//            self.passedTrajectory = MAPolyline.init(coordinates: &(self.coordinatesBuffer), count: UInt(bufferCount) - 1)
//            self.mapView.remove(self.passedTrajectory)
            
//            buffer.deallocate(capacity: bufferCount)
        }
    }
    
    func coordinatesList() {
        waypointCoordinates.removeAll()
        if self.mapController?.wayPoints() != nil {
            for point in self.mapController!.wayPoints() {
                let pointCoordinate: CLLocationCoordinate2D = point.coordinate
                waypointCoordinates.append(pointCoordinate)
            }
            print("\(self.waypointCoordinates.count)")
        }
    }
    
    func missionTotalDistance() -> Double {
        var sum: Double = 0.0
        let count = (self.mapController?.editPoints.count)!
        for i in 0..<count-1 {
            let begin = CLLocation(latitude: self.aircraftCoords[i].latitude, longitude: self.aircraftCoords[i].longitude)
            let end = CLLocation.init(latitude: self.aircraftCoords[i+1].latitude, longitude: self.aircraftCoords[i+1].longitude)
            let distance = begin.distance(from: end)
            distanceArray.append(Double(distance))
            sum += distance
        }
        sumDistance = sum
        return sum
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
