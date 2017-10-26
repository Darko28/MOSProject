//
//  DJIGSButtonController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/23.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

enum DJIGSViewMode {
    case ViewMode
    case EditMode
}

protocol DJIGSButtonControllerDelegate {
    func focusMapBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController)
    func switchToMode(_ mode: DJIGSViewMode, inGSButtonVC gsbtnVC: DJIGSButtonController)
    func addBtn(button: UIButton, withActionInGSButtonVC GSBtnVC: DJIGSButtonController)
    func clearBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController)
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController)
    func stopBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController)
    func configBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonController)
}

class DJIGSButtonController: UIViewController {
    
    @IBOutlet weak var focusMapBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var configBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    var mode: DJIGSViewMode = .ViewMode
    var delegate: DJIGSButtonControllerDelegate!
    
    @IBAction func focusMapBtnAction(_ sender: UIButton) {
        delegate.focusMapBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func editBtnAction(_ sender: UIButton) {
        self.setMode(mode: DJIGSViewMode.EditMode)
        delegate.switchToMode(self.mode, inGSButtonVC: self)
    }
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        delegate.addBtn(button: sender, withActionInGSButtonVC: self)
    }
    
    @IBAction func backBtnAction(_ sednder: UIButton) {
        self.setMode(mode: DJIGSViewMode.ViewMode)
        delegate.switchToMode(mode, inGSButtonVC: self)
    }
    
    @IBAction func clearBtnAction(_ sender: UIButton) {
        delegate.clearBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func startBtnAction(_ sender: UIButton) {
        delegate.startBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func stopBtnAction(_ sender: UIButton) {
        delegate.stopBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func configBtnAction(_ sender: UIButton) {
        delegate.configBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    func setMode(mode: DJIGSViewMode) {
        self.mode = mode
        self.editBtn.isHidden = (mode == DJIGSViewMode.EditMode)
        self.focusMapBtn.isHidden = (mode == DJIGSViewMode.EditMode)
        self.addBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
        self.backBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
        self.clearBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
        self.startBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
        self.stopBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
        self.configBtn.isHidden = (mode == DJIGSViewMode.ViewMode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setMode(mode: DJIGSViewMode.ViewMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
