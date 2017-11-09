//
//  DJIRootViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK

class DJIRootViewController: UIViewController, MAMapViewDelegate, CLLocationManagerDelegate, DJIGSButtonControllerDelegate, DJIFlightControllerDelegate, DJIWaypointConfigViewControllerDelegate, UITextFieldDelegate, DJISDKManagerDelegate {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    var createWaypointButton: UIButton!
    
    var latitudeLabel: UILabel!
    var longitudeLabel: UILabel!
    var latitudeTxt: UITextField!
    var longitudeTxt: UITextField!
    
    var uploadBtn: UIButton!
    
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
//        if CLLocationCoordinate2DIsValid(self.droneLocation!) {
//            self.focusMap()
//        }
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
//        self.mapView.showsUserLocation = true
//        self.mapView.userTrackingMode = .follow
        
        self.gsButtonVC = DJIGSButtonController(nibName: "DJIGSButtonController", bundle: Bundle.main)
        if self.gsButtonVC != nil {
            self.gsButtonVC?.view.frame = CGRect(x: 10, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 48), width: self.gsButtonVC!.view.frame.size.width, height: self.gsButtonVC!.view.frame.size.height)
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
        
        self.createWaypointButton = UIButton(frame: CGRect(x: 10, y: ((self.gsButtonVC?.view.frame.size.height)! + self.topView.frame.origin.y + self.topView.frame.size.height + 48), width: 64, height: 24))
        self.createWaypointButton.backgroundColor = UIColor.darkGray
        self.createWaypointButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.createWaypointButton.titleLabel?.textColor = UIColor.white
        self.createWaypointButton.setTitle("Set", for: .normal)
        self.createWaypointButton.addTarget(self, action: #selector(createWaypoints(_:)), for: .touchUpInside)
        self.createWaypointButton.isHidden = true
        self.mapView.addSubview(self.createWaypointButton)
        
        self.latitudeLabel = UILabel(frame: CGRect(x: self.mapView.bounds.size.width - 215, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 28), width: 80, height: 20))
        self.latitudeLabel.text = "latitude:"
        self.mapView.addSubview(self.latitudeLabel)
        
        self.latitudeTxt = UITextField(frame: CGRect(x: self.mapView.bounds.size.width - 130, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 28), width: 120, height: 20))
//        self.latitudeTxt.backgroundColor = UIColor.lightGray
        self.latitudeTxt.borderStyle = .roundedRect
        self.mapView.addSubview(self.latitudeTxt)
        
        self.longitudeLabel = UILabel(frame: CGRect(x: self.mapView.bounds.size.width - 215, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 52), width: 80, height: 20))
        self.longitudeLabel.text = "longitude:"
        self.mapView.addSubview(self.longitudeLabel)
        
        self.longitudeTxt = UITextField(frame: CGRect(x: self.mapView.bounds.size.width - 130, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 52), width: 120, height: 20))
        self.longitudeTxt.borderStyle = .roundedRect
        self.mapView.addSubview(self.longitudeTxt)
        
        self.uploadBtn = UIButton(frame: CGRect(x: self.mapView.bounds.size.width - 160, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 84), width: 64, height: 20))
        self.uploadBtn.setTitle("upload", for: .normal)
        self.uploadBtn.setTitleColor(.black, for: .normal)
        self.uploadBtn.addTarget(self, action: #selector(uploadCoordinates(_:)), for: .touchUpInside)
        self.mapView.addSubview(self.uploadBtn)
    }
    
    override func viewDidLayoutSubviews() {
            self.updateUI()
    }
    
    func updateUI() {
        self.latitudeLabel.removeFromSuperview()
        self.longitudeLabel.removeFromSuperview()
        self.latitudeTxt.removeFromSuperview()
        self.longitudeTxt.removeFromSuperview()
        self.uploadBtn.removeFromSuperview()
        
        self.latitudeLabel = UILabel(frame: CGRect(x: self.mapView.bounds.size.width - 215, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 28), width: 80, height: 20))
        self.latitudeLabel.text = "latitude:"
        self.mapView.addSubview(self.latitudeLabel)
        
        self.latitudeTxt = UITextField(frame: CGRect(x: self.mapView.bounds.size.width - 130, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 28), width: 120, height: 20))
        //        self.latitudeTxt.backgroundColor = UIColor.lightGray
        self.latitudeTxt.borderStyle = .roundedRect
        self.mapView.addSubview(self.latitudeTxt)
        
        self.longitudeLabel = UILabel(frame: CGRect(x: self.mapView.bounds.size.width - 215, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 52), width: 80, height: 20))
        self.longitudeLabel.text = "longitude:"
        self.mapView.addSubview(self.longitudeLabel)
        
        self.longitudeTxt = UITextField(frame: CGRect(x: self.mapView.bounds.size.width - 130, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 52), width: 120, height: 20))
        self.longitudeTxt.borderStyle = .roundedRect
        self.mapView.addSubview(self.longitudeTxt)
        
        self.uploadBtn = UIButton(frame: CGRect(x: self.mapView.bounds.size.width - 160, y: (self.topView.frame.origin.y + self.topView.frame.size.height + 84), width: 64, height: 20))
        self.uploadBtn.setTitle("upload", for: .normal)
        self.uploadBtn.setTitleColor(.black, for: .normal)
        self.uploadBtn.addTarget(self, action: #selector(uploadCoordinates(_:)), for: .touchUpInside)
        self.mapView.addSubview(self.uploadBtn)
        
        self.latitudeTxt.delegate = self
        self.longitudeTxt.delegate = self
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
            if ENTER_DEBUG_MODE {
                DJISDKManager.enableBridgeMode(withBridgeAppIP: DEBUG_ID)
            }
//            self.productConnected(DJISDKManager.product())
            self.appDelegate?.model?.addLog(newLogEntry: "waypoint registration succeed")
            DJISDKManager.startConnectionToProduct()
        }
    }

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
        self.appDelegate?.model?.addLog(newLogEntry: "\(self.droneLocation ?? CLLocationCoordinate2D(latitude: 180,longitude: 180))")
//        if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            var region: MACoordinateRegion = MACoordinateRegion()
            if self.homeLocation != nil {
                self.homeAnnotation = MAPointAnnotation()
                homeAnnotation?.coordinate = self.homeLocation!
                homeAnnotation?.title = "home pm2.5"
                homeAnnotation?.subtitle = "home pm10"
                mapView.addAnnotation(self.homeAnnotation)
//                region.center = AMapCoordinateConvert(self.droneLocation!, .GPS)
                region.center = self.homeLocation!
                region.span.latitudeDelta = 0.001
                region.span.longitudeDelta = 0.001
                mapView.setRegion(region, animated: true)
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "drone location nil")
                print("location nil")
            }
    }
    
    @objc func singleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        print("single tap")
        if !self.isEditingPoints && self.waypointConfigVC?.view.alpha == 1 {
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
                    self.mapView.removeGestureRecognizer(cancelTapGesture!)
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
//        if !self.isEditingPoints {
            if self.aircraftStatus?.aircraftLocation?.coordinate != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "create waypoint")
                let aircraftCoordinate: CLLocationCoordinate2D = (self.aircraftStatus?.aircraftLocation?.coordinate)!
                let horizontalVelocity = (self.aircraftStatus?.velocityX == 0 && self.aircraftStatus?.velocityY == 0) ? 0.0 : 1.0
                
                self.mapController?.createWaypoint(waypointCoordinate: aircraftCoordinate, with: horizontalVelocity, with: self.mapView)
                
                if mapController?.editPoints.count != 0 {
                    for coord in (self.mapController?.editPoints)! {
                        aircraftCoords.append(coord.coordinate)
                    }
                }
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "aircraft location is nil")
        }
//        }
    }
    
    @objc func uploadCoordinates(_ sender: UIButton) {
        print("upload coordinates")
        self.appDelegate?.model?.addLog(newLogEntry: "Upload coordinates")
        if self.latitudeTxt.text != "" && self.longitudeTxt.text != "" {
            let uploadLatitude: Double = ((self.latitudeTxt.text)! as NSString).doubleValue
            let uploadLongitude: Double = ((self.longitudeTxt.text)! as NSString).doubleValue
            
            let uploadCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: uploadLatitude, longitude: uploadLongitude)
            print("\(uploadCoordinate)")
            
            if CLLocationCoordinate2DIsValid(uploadCoordinate) {
                self.mapController?.uploadCoordinates(waypointCoordinate: uploadCoordinate, with: self.mapView)
                
                if mapController?.editPoints.count != 0 {
                    for coord in (self.mapController?.editPoints)! {
                        aircraftCoords.append(coord.coordinate)
                    }
                }
            } else {
                let alertController = UIAlertController(title: "Upload waypoints", message: "upload coordinate is invalid", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        } else {
            print("coordinate text is nil")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("textField did end editing")
//        textField.resignFirstResponder()
//    }
    
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
            self.createWaypointButton.isHidden = false
        } else {
            self.createWaypointButton.isHidden = true
        }
    }
    
    func clearBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        let alertController: UIAlertController = UIAlertController(title: "Clear waypoint & trace", message: "Clear both?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.mapController?.clearAllPointsInMapView(self.mapView)
            if self.passedTrajectory != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "remove passed trajectory")
                //            let trajectoryCount = self.coordinatesBuffer.count
                //            for _ in 0..<trajectoryCount {
                //                self.mapView.remove(self.passedTrajectory)
                self.clearAllTrajectoryInMapView(mapView: self.mapView)
                self.mapView.remove(self.passedTrajectory)
                self.coordinatesBuffer.removeAll()
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "passedTrajectory is nil")
            }
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            if self.passedTrajectory != nil {
                self.appDelegate?.model?.addLog(newLogEntry: "remove passed trajectory")
                //            let trajectoryCount = self.coordinatesBuffer.count
                //            for _ in 0..<trajectoryCount {
                //                self.mapView.remove(self.passedTrajectory)
                self.clearAllTrajectoryInMapView(mapView: self.mapView)
                self.mapView.remove(self.passedTrajectory)
                self.coordinatesBuffer.removeAll()
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "passedTrajectory is nil")
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func clearAllTrajectoryInMapView(mapView: MAMapView) {
        if self.passedTrajectory != nil {
            coordinatesBuffer.removeAll()
            var overlays = mapView.overlays
            for i in 0 ..< overlays!.count {
                let overlay = overlays![i]
                mapView.remove(overlay as! MAOverlay)
//                if !((overlay as AnyObject).isEqual(self.aircraftAnnotation)) {
//                    mapView.removeAnnotation(anno as! MAAnnotation)
//                }
            }
        }
    }
    
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        print("Start waypoint mission!")
        self.missionOperator?.startMission(completion: { [weak self] (error) in
            if error != nil {
                let alertController = UIAlertController(title: "Start waypoint mission error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)

                self!.appDelegate?.model?.addLog(newLogEntry: "start waypoint mission failed with error: \(error!.localizedDescription)")
                print("start waypoint mission failed with error: \(error!.localizedDescription)")
            } else {
                let alertController = UIAlertController(title: "Waypoint mission start successfully", message: "Waypoint mission started!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)

                self!.appDelegate?.model?.addLog(newLogEntry: "start waypoint mission succeeded!")
                print("start waypoint mission succeeded!")
            }
        })
    }
    
    func stopBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        print("stop waypoint mission")
        self.missionOperator?.stopMission(completion: { [weak self] (error) in
            if error != nil {
                let alertController = UIAlertController(title: "Stop waypoint mission error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)
                self!.appDelegate?.model?.addLog(newLogEntry: "stop waypoint mission failed with error: \(error!.localizedDescription)")
            } else {
                let alertController = UIAlertController(title: "Stop waypoint mission", message: "Stop waypoint mission successfully", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)
                self!.appDelegate?.model?.addLog(newLogEntry: "stop waypoint mission succeed.")
            }
        })
    }
    
    func configBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController) {
        self.mapView.addGestureRecognizer(cancelTapGesture!)
        self.waypointConfigVC?.singleTap.isEnabled = false
        
        self.coordinatesList()
        
        var waypoints = self.mapController?.wayPoints()
        if( waypoints == nil || (waypoints?.count)! < 2) {
            print("No or not enough waypoints for waypoint mission")
            let alertController = UIAlertController(title: "Waypoint mission error!", message: "No or not enough waypoints for waypoint mission", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
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
                let waypoint: DJIWaypoint = DJIWaypoint(coordinate: (location?.coordinate)!)
                waypoint.cornerRadiusInMeters = 20.0
                
                self.waypointMission?.add(waypoint)
            }
        }
    }
    
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController) {
        
        self.mapView.removeGestureRecognizer(cancelTapGesture!)
        
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
        
        self.missionOperator?.uploadMission(completion: { [weak self] (error) in
            if error != nil {
                print("Upload mission failed")
                self!.appDelegate?.model?.addLog(newLogEntry: "Upload mission failed")
                let alertController = UIAlertController(title: "Upload mission failed!", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)
            } else {
                self!.appDelegate?.model?.addLog(newLogEntry: "upload mission succeed")
                print("Upload mission succeed!")
                let alertController = UIAlertController(title: "Upload mission succeed!", message: "Upload waypoint mission succeed!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)
            }
        })
        
        self.missionOperator?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { [weak self] (error) in
            if error != nil {
                print("Mission execution failed")
                self!.appDelegate?.model?.addLog(newLogEntry: "mission execution failed")
                let alertController = UIAlertController(title: "Mission execution failed!", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)

            } else {
                self!.appDelegate?.model?.addLog(newLogEntry: "mission execution succeed")
                self?.appDelegate?.model?.addLog(newLogEntry: "\(self!.missionTotalDistance())")
//                self.mapController?.editPoints.removeAll()
                print("Mission execution finished")
                let alertController = UIAlertController(title: "Mission finished!", message: "Mission execution finished", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self!.present(alertController, animated: true, completion: nil)
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
    
    var aircraftAnnoView: DJIAircraftAnnotationView!
    
    public typealias MOSGoActionBlock = (NSNumber, NSArray) -> Void
    var goAction: MOSGoActionBlock?
    
    var actionModel: MOSAction? = MOSAction()
    var section: MOSSection? = MOSSection()
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: DJIAircraftAnnotation.self) {
            let aircraftReuseIdentifier = "Aircraft_Annotation"
            print("aircraft annotation")
            
            var aircraftView: MAAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: aircraftReuseIdentifier)
            if aircraftView == nil {
                aircraftView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: aircraftReuseIdentifier)
            }
            aircraftAnnoView = aircraftView as! DJIAircraftAnnotationView
            aircraftAnnoView.image = UIImage(named: "aircraft.png")
            aircraftAnnoView.canShowCallout = false
//            (aircraftView as! DJIAircraftAnnotationView).image = UIImage(named: "aircraft.png")
//            (aircraftView as! DJIAircraftAnnotationView).canShowCallout = false
            
            
            // Onboard Communication
            let allSections = self.appDelegate!.model!.jsonSections
            
            //            for index in 0..<allSections!.count {
            //                let section = allSections![index]
            //                self.section = section
            //            }
            
            self.section = allSections?.last
            
            let action: MOSAction? = self.section!.actions!.last
            
            aircraftAnnoView.populateWithActionModel(actionModel: action!)
            
            aircraftAnnoView?.goAction = { [weak aircraftAnnoView] (cmdId: NSNumber, arguments: NSArray) in
                
                print("annotationView goAction")
                
                var cmdIdUInt = cmdId.uintValue
                let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
                
                    aircraftAnnoView?.calloutView?.setTitle(title: "Sending...")
                
                self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
                    self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
                        aircraftAnnoView?.calloutView?.setTitle(title: "Command sent!")
                }, and: { [weak self] (data, error) in
                    let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
                    print("ackData: \(ackData)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.bytes)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.length)")
                    
                    var ackValue: UInt16 = 7
                    ackData.getBytes(&ackValue, length: UInt16.bitWidth)
                    print("\(UInt16.bitWidth)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "\(UInt16.bitWidth)")
                    
                    let responseMessage = "Ack: \(ackValue)"
                    self!.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
                    
                        aircraftAnnoView?.calloutView?.setTitle(title: responseMessage)
                })
            }
            return aircraftAnnoView
            
        } else if (annotation.isKind(of: MAPointAnnotation.self)) {
            
            print("point annotation")
            let pointReuseIdentifier = "Pin_Annotation"
            //            let pinView: MAPinAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            var annotationView: CustomWaypointAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier) as! CustomWaypointAnnotationView!
            if annotationView == nil {
                annotationView = CustomWaypointAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
                annotationView.canShowCallout = false
            }
            
            // Onboard Communication
            let allSections = self.appDelegate!.model!.jsonSections
            
//            for index in 0..<allSections!.count {
//                let section = allSections![index]
//                self.section = section
//            }
            
            self.section = allSections?.first
            
            let action: MOSAction? = self.section!.actions![1]
            
            annotationView.populateWithActionModel(actionModel: action!)
                        
            annotationView.goAction = { [weak annotationView] (cmdId: NSNumber, arguments: NSArray) in
                
                print("annotationView goAction")
                
                var cmdIdUInt = cmdId.uintValue
                let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
                
                    annotationView?.calloutView?.setTitle(title: "Sending...")
                
                self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
                    self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
                        annotationView?.calloutView?.setTitle(title: "Command sent!")
                }, and: { [weak self] (data, error) in
                    let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
                    print("ackData: \(ackData)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.bytes)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.length)")
                    
                    var ackValue: UInt16 = 7
                    ackData.getBytes(&ackValue, length: UInt16.bitWidth)
                    print("\(UInt16.bitWidth)")
                    self?.appDelegate?.model?.addLog(newLogEntry: "\(UInt16.bitWidth)")
                    
                    let responseMessage = "Ack: \(ackValue)"
                    self!.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
                    
                        annotationView?.calloutView?.setTitle(title: responseMessage)
                })
            }
            
//            if annotationView.goAction != nil {
//
//                print("annotationView goAction is not nil")
//
//                let cmdId: NSNumber? = self.actionModel?.cmdID
//                let arguments = NSArray()
//
//                annotationView.goAction!(cmdId!, arguments)
//            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        
//        DispatchQueue.global().async {
        
            if view.isKind(of: MAPinAnnotationView.self) {
                // Onboard Communication
                let allSections = self.appDelegate!.model!.jsonSections
                
                //        for index in 0..<allSections!.count {
                //            let section = allSections![index]
                //            self.section = section
                //        }
                
                self.section = allSections?.first
                
                let action: MOSAction? = self.section!.actions![1]
                
                let annotationView = view as! CustomWaypointAnnotationView
                
                annotationView.populateWithActionModel(actionModel: action!)
                
                annotationView.goAction = { [weak annotationView] (cmdId: NSNumber, arguments: NSArray) in
                    
                    print("annotationView goAction")
                    
                    var cmdIdUInt = cmdId.uintValue
                    let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
                    
                        annotationView?.calloutView?.setTitle(title: "Sending...")
                    
                    self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
                        self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
                            annotationView?.calloutView?.setTitle(title: "Command sent!")
                    }, and: { [weak self] (data, error) in
                        let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
                        print("ackData: \(ackData)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.bytes)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.length)")
                        
                        var ackValue: UInt16 = 7
                        ackData.getBytes(&ackValue, length: UInt16.bitWidth)
                        print("\(UInt16.bitWidth)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "\(UInt16.bitWidth)")
                        
                        let responseMessage = "Ack: \(ackValue)"
                        self!.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
                        
                            annotationView?.calloutView?.setTitle(title: responseMessage)
                    })
                }
                
            } else if view.isKind(of: DJIAircraftAnnotationView.self) {
                // Onboard Communication
                let allSections = self.appDelegate!.model!.jsonSections
                
                //            for index in 0..<allSections!.count {
                //                let section = allSections![index]
                //                self.section = section
                //            }
                
                self.section = allSections?.last
                
                let action: MOSAction? = self.section!.actions!.last
                
                self.aircraftAnnoView.populateWithActionModel(actionModel: action!)
                
                self.aircraftAnnoView?.goAction = { (cmdId: NSNumber, arguments: NSArray) in
                    
                    print("annotationView goAction")
                    
                    var cmdIdUInt = cmdId.uintValue
                    let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
                    
                        self.aircraftAnnoView?.calloutView?.setTitle(title: "Sending...")
                    
                    self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
                        self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
                            self.aircraftAnnoView?.calloutView?.setTitle(title: "Command sent!")
                    }, and: { [weak self] (data, error) in
                        let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
                        print("ackData: \(ackData)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.bytes)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "ackData: \(ackData.length)")
                        
                        var ackValue: UInt16 = 7
                        ackData.getBytes(&ackValue, length: UInt16.bitWidth)
                        print("\(UInt16.bitWidth)")
                        self?.appDelegate?.model?.addLog(newLogEntry: "\(UInt16.bitWidth)")
                        
                        let responseMessage = "Ack: \(ackValue)"
                        self!.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
                        
                            self!.aircraftAnnoView?.calloutView?.setTitle(title: responseMessage)
                    })
                }
            }
//        }
        
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
    }

    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        
            self.fc = fc
            self.aircraftStatus = state
            self.droneLocation = state.aircraftLocation?.coordinate
            ////            MATraceManager.sharedInstance().queryProcessedTrace(with: [MATraceLocation], type: , processingCallback: , finishCallback: , failedCallback: )
            //
            //        }
            
            if self.droneLocation != nil {
                self.homeLocation = AMapCoordinateConvert((state.aircraftLocation?.coordinate)!, .GPS)
                self.droneLocation = AMapCoordinateConvert((state.aircraftLocation?.coordinate)!, .GPS)
                self.mapController!.updateAircraftLocation(self.droneLocation!, withMapView: self.mapView)
                let radianYaw = ((state.attitude.yaw) * .pi / 180.0)
                self.aircraftAnnoView?.rotateDegree = CGFloat(radianYaw)
                //            if mapController?.editPoints.count == 0 {
                //                self.aircraftAnnotation.coordinate = droneLocation!
                //            }
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "aircraftLocation is nil")
            }
            
            self.modeLabel.text = state.flightModeString
            self.gpsLabel.text = String(format: "%d", state.satelliteCount)
            self.vsLabel.text = String(format: "%.1f M/S", -(state.velocityZ))
            self.hsLabel.text = NSString.localizedStringWithFormat("%0.1f M/S", sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)) as String
            self.altitudeLabel.text = String(format: "%.1f M", state.altitude)
            
            if self.missionOperator?.currentState == DJIWaypointMissionState.executing {
                if state.aircraftLocation != nil {
                    //            buffer[passedCoordinatesCount] = state.aircraftLocation!.coordinate
                    self.coordinatesBuffer.append(self.droneLocation!)
                    self.passedCoordinatesCount = self.coordinatesBuffer.count
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
            self.passedTrajectory = MAPolyline.init(coordinates: &(self.coordinatesBuffer), count: UInt(bufferCount) - 1)
            self.mapView.remove(self.passedTrajectory)
            
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
