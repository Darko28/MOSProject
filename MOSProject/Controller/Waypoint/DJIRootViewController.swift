//
//  DJIRootViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK

class DJIRootViewController: UIViewController, MAMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIGSButtonControllerDelegate, DJIFlightControllerDelegate, DJIWaypointConfigViewControllerDelegate {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    
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
//    var missionManager: DJIMutableWaypointMission? = DJIMutableWaypointMission()
    
    var missionOperator: DJIWaypointMissionOperator? = {
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerApp()
        self.initUI()
        self.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    
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
        self.view.addSubview(mapView)
        
        self.view.addSubview(topView)

        self.gsButtonVC = DJIGSButtonController(nibName: "DJIGSButtonController", bundle: Bundle.main)
        if self.gsButtonVC != nil {
            self.gsButtonVC!.view.frame = CGRect(x: 10, y: 88, width: self.gsButtonVC!.view.frame.size.width, height: self.gsButtonVC!.view.frame.size.height)
        }
        self.gsButtonVC!.delegate = self
        self.view.addSubview(gsButtonVC!.view)
        
        self.waypointConfigVC = DJIWaypointConfigViewController(nibName: "DJIWaypointConfigViewController", bundle: Bundle.main)
        self.waypointConfigVC?.view.alpha = 0
        self.waypointConfigVC?.view.autoresizingMask = UIViewAutoresizing(rawValue: (UIViewAutoresizing.flexibleLeftMargin.rawValue)|(UIViewAutoresizing.flexibleRightMargin.rawValue)|(UIViewAutoresizing.flexibleTopMargin.rawValue)|(UIViewAutoresizing.flexibleBottomMargin.rawValue))
        let configVCOriginX = (self.view.frame.width - (self.waypointConfigVC?.view.frame.width)!) / 2
        let configVCOriginY = 88
        self.waypointConfigVC?.view.frame = CGRect(x: configVCOriginX, y: CGFloat(configVCOriginY), width: (self.waypointConfigVC?.view.frame.width)!, height: (self.waypointConfigVC?.view.frame.height)!)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.waypointConfigVC?.view.center = self.view.center
        }
        
        self.waypointConfigVC?.delegate = self
        self.view.addSubview((self.waypointConfigVC?.view)!)
        
        
        self.initCoordinates()
        self.movingAnnotation = MAAnimatedAnnotation()
        self.movingAnnotation.coordinate = self.coords1.first!
        self.mapView.addAnnotation(self.movingAnnotation)
        
        self.mapView.addAnnotation(self.aircraftAnnotation)

        let polyline1: MAPolyline! = MAPolyline(coordinates: &(self.coords1), count: UInt(self.coords1.count))
        
        self.mapView.add(polyline1)
        
        self.initButtons()
    }
    
    func initData() {
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.mapController = DJIMapController()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWaypoints(_:)))
        self.mapView.addGestureRecognizer(self.tapGesture!)
//        self.aircraftAnnotation.coordinate = self.aircraftCoords.first!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addWaypoints(_ tapGesture: UITapGestureRecognizer) {
        let point: CGPoint = tapGesture.location(in: self.mapView)
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.appDelegate?.model?.addLog(newLogEntry: "add point")
                print("add points")
                self.mapController!.addPoint(point, withMapView: self.mapView)
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
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            print("point annotation")
            let pointReuseIdentifier = "Pin_Annotation"
//            let pinView: MAPinAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            var annotationView: MAPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier) as! MAPinAnnotationView!
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
                let img = UIImage(named: "aircraft.png")
                annotationView.image = img
            }
            
            return annotationView
//            pinView.tintColor = UIColor.purple
//            pinView.pinColor = .purple
//            pinView.image = UIImage(named: "aircraft.png")
//            return pinView
            
        } else if annotation.isKind(of: DJIAircraftAnnotation.self) {
            print("aircraft annotation")
            let annoView: DJIAircraftAnnotationView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            annoView.updateImage(image: UIImage(named: "aircraft.png"))
            return annoView
        }
        return nil
    }
    
    func focusMap() {
        if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            var region: MACoordinateRegion = MACoordinateRegion()
            if self.droneLocation != nil {
                region.center = self.droneLocation!
                region.span.latitudeDelta = 0.001
                region.span.longitudeDelta = 0.001
                mapView.setRegion(region, animated: true)
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "drone location nil")
                print("location nil")
            }
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "droneLocation is invalid")
            print("droneLocation is invalid")
        }
    }
    
    func appRegisteredWithError(_ error: Error?) {
        if error != nil {
            print("DJI SDK register failed!")
            let alertController = UIAlertController(title: "DJISDK Register", message: "\(error!.localizedDescription)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        } else {
            print("DJI SDK register succeed!")
            DJISDKManager.enableBridgeMode(withBridgeAppIP: "192.168.1.105")
            DJISDKManager.startConnectionToProduct()
            if DJISDKManager.startConnectionToProduct() == true {
                self.appDelegate?.model?.addLog(newLogEntry: "Product connected")
                print("Product connected")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "Product not recognized")
                print("product not recognized")
            }
        }
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            let flightController = (DJISDKManager.product() as? DJIAircraft)?.flightController
            flightController?.delegate = self
        }
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if error != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "Login failed")
                print("Login failed")
            }
        }
    }
    
    func addBtn(button: UIButton, withActionInGSButtonVC GSBtnVC: DJIGSButtonController) {
        if self.isEditingPoints {
            self.isEditingPoints = false
            button.setTitle("Add", for: UIControlState.normal)
            self.coordinatesList()
            self.drawTrace()
        } else {
            self.isEditingPoints = true
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
        self.mapController?.clearAllPointsInMapView(self.mapView)
    }
    
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        print("Start waypoint mission!")
        self.missionOperator?.startMission(completion: { (error) in
            if error != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "start waypoint mission failed with error: \(error!.localizedDescription)")
                print("start waypoint mission failed with error: \(error!.localizedDescription)")
                
                self.aircraftAnnotation.coordinate = (self.mapController?.pointList[0])!
                let speed = sqrtf(self.aircraftState!.velocityX * self.aircraftState!.velocityX + self.aircraftState!.velocityY * self.aircraftState!.velocityY)
                let durationTime = self.missionTotalDistance() / Double(speed)
                print("\(speed)")
                print("\(durationTime)")
                self.appDelegate?.model?.addLog(newLogEntry: "\(durationTime)")
                self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.mapController!.pointList), count: UInt(self.mapController!.editPoints.count), withDuration: CGFloat(durationTime), withName: nil, completeCallback: nil)
                
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
                let waypoint: DJIWaypoint = DJIWaypoint(coordinate: location!.coordinate)
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
        
        self.missionOperator?.load(self.waypointMission!)
        
        self.missionOperator?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error) in
            if error != nil {
                print("Mission execution failed")
                self.appDelegate?.model?.addLog(newLogEntry: "mission execution failed")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "mission execution failed")
                print("Mission execution finished")
            }
        })
        
        self.missionOperator?.uploadMission(completion: { (error) in
            if error != nil {
                print("Upload mission failed")
                self.appDelegate?.model?.addLog(newLogEntry: "Upload mission failed")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "upload mission succeed")
                print("Upload mission succeed!")
            }
        })
    }
    
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.waypointConfigVC?.view.alpha = 0
        }
    }
    
//    func startUpdateLoaction() {
//        if CLLocationManager.locationServicesEnabled() {
////            if self.locationManager == nil {
//                self.locationManager = CLLocationManager()
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                locationManager.distanceFilter = 0.1
//                if locationManager.responds(to: #selector(locationManager.requestAlwaysAuthorization)) {
//                    self.locationManager.requestAlwaysAuthorization()
//                }
//                locationManager.startUpdatingLocation()
////            }
//        } else {
//            print("start update location failed")
//        }
//    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location: CLLocation = locations.last!
//    }
    
    var aircraftCoords: Array<CLLocationCoordinate2D> = []
    var aircraftAnnotation: MAAnimatedAnnotation! = MAAnimatedAnnotation()
    
    var aircraftState: DJIFlightControllerState?
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        
        self.aircraftState = state
        self.droneLocation = state.aircraftLocation!.coordinate
//        print("\(droneLocation!.latitude) \(droneLocation!.longitude)")
        
//        aircraftCoords.append(state.aircraftLocation!.coordinate)
        
        self.modeLabel.text = state.flightModeString
        self.gpsLabel.text = String(format: "%d", state.satelliteCount)
        self.vsLabel.text = String(format: "%.1f M/S", state.velocityZ)
        self.hsLabel.text = NSString.localizedStringWithFormat("%0.1f M/S", sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)) as String
        self.altitudeLabel.text = String(format: "%.1f M", state.altitude)
        
        
        
        
        if mapController?.editPoints.count != 0 {
//            for coord in (self.mapController?.editPoints)! {
//                aircraftCoords.append(coord.coordinate)
//            }
//            self.aircraftAnnotation.coordinate = (self.mapController?.pointList.first)!
//            self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.mapController!.pointList), count: UInt(self.mapController!.editPoints.count), withDuration: 1, withName: nil, completeCallback: nil)
//            self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.mapController!.pointList), count: UInt(self.mapController!.editPoints.count), withDuration: 5, withName: nil, completeCallback: nil, stepCallback: { (_) in
//                self.mapController?.updateHeading(CGFloat((state.attitude.yaw) * .pi / 180))
//            })
//            print("\(self.mapController!.editPoints.count)")
//            self.aircraftAnnotation.coordinate = (self.mapController?.pointList[0])!
//            let speed = sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)
//            let durationTime = missionTotalDistance() / Double(speed)
//            self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.mapController!.pointList), count: UInt(self.mapController!.editPoints.count), withDuration: CGFloat(durationTime), withName: nil, completeCallback: nil)
        } else {
            self.aircraftAnnotation.coordinate = droneLocation!
        }
        
//        print("\(self.mapController!.pointList.count)")
//        print("\(String(describing: self.mapController?.editPoints.count))")
        
        if self.droneLocation != nil {
            self.mapController!.updateAircraftLocation(self.droneLocation!, withMapView: self.mapView)
            if self.mapController!.aircraftAnnotation == nil {
                print("aircraftAnnotation is nil, create an DJIAircraftAnnotation")
                self.mapController!.aircraftAnnotation = DJIAircraftAnnotation(coordinate: self.droneLocation!)
                mapView.addAnnotation(self.mapController!.aircraftAnnotation)
            }
     }

        let radianYaw = ((state.attitude.yaw) * .pi / 180.0)
//        print("\(radianYaw)")
        self.mapController!.updateHeading(CGFloat(radianYaw))
        self.mapController!.updateAircraftHeading(CGFloat(radianYaw))
        
    }
    
    
    var waypointCoordinates: Array<CLLocationCoordinate2D> = []
    var waypointTrace: MAPolyline?
    
    var distanceArray = [Double]()
    var sumDistance: Double = 0.0
    
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
    
    func drawTrace() {
        self.waypointTrace = MAPolyline(coordinates: &(self.waypointCoordinates), count: UInt(self.waypointCoordinates.count))
        self.mapView.add(self.waypointTrace)
    }
    
    
    func coordinatesList() {
        if self.mapController?.wayPoints() != nil {
            for point in self.mapController!.wayPoints() {
                let pointCoordinate: CLLocationCoordinate2D = point.coordinate
                waypointCoordinates.append(pointCoordinate)
            }
            print("\(self.waypointCoordinates.count)")
        }
    }
    
    
    
    
    
    
    var movingAnnotation: MAAnimatedAnnotation!
    var coords1: Array<CLLocationCoordinate2D> = []

    func initCoordinates() {
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.852136, longitude: 116.30095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.852136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.932136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.932136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.982136, longitude: 116.48095))
    }

    func generateStarPoints(center: CLLocationCoordinate2D) {
        let STAR_RADIUS = 0.05
        let PI = 3.1415926
        let starRaysCount = 5
        var i = 0

        while i < starRaysCount {
            var angle = 2.0 * Double.init(i) / Double(starRaysCount) * PI
            var index = 2 * i
            coords1.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS * sin(angle) + center.latitude, longitude: STAR_RADIUS * cos(angle) + center.longitude))

            index += 1
            angle = angle + 1.0/Double(starRaysCount) * PI

            coords1.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS/2.0 * sin(angle) + center.latitude, longitude: STAR_RADIUS/2.0 * cos(angle) + center.longitude))

            i += 1
        }
    }

    @objc func button1() {
        self.movingAnnotation.coordinate = coords1[0]
        self.movingAnnotation.addMoveAnimation(withKeyCoordinates: &(self.coords1), count: UInt(self.coords1.count), withDuration: 5, withName: nil, completeCallback: nil)
//        self.aircraftAnnotation.addMoveAnimation(withKeyCoordinates: &(self.coords3), count: UInt(self.coords2.count), withDuration: 5, withName: nil, completeCallback: nil)
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

    func initButtons() {
        let button1 = UIButton(type: .roundedRect)
        button1.frame = CGRect(x: 80, y: 250, width: 70, height: 25)
        button1.backgroundColor = .red
        button1.setTitle("GO", for: .normal)
        button1.addTarget(self, action: #selector(self.button1), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button1)
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
