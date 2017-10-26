//
//  DJIWaypointConfigViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/24.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

protocol DJIWaypointConfigViewControllerDelegate {
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController)
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigViewController)
}

class DJIWaypointConfigViewController: UIViewController {
    
    @IBOutlet weak var altitudeTextfield: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!
    
    var delegate: DJIWaypointConfigViewControllerDelegate?
    
    @IBAction func finishBtnAction(_ sender: UIButton) {
        delegate?.finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        delegate?.cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        self.altitudeTextfield.text = "30"
        self.autoFlightSpeedTextField.text = "8"
        self.maxFlightSpeedTextField.text = "10"
        self.actionSegmentedControl.selectedSegmentIndex = 1
        self.headingSegmentedControl.selectedSegmentIndex = 0
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
