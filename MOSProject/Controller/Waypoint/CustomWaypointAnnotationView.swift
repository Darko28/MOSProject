//
//  CustomWaypointAnnotationView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/30.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK


let kCalloutWidth: CGFloat = 180.0
let kCalloutHeight: CGFloat = 64.0

class CustomWaypointAnnotationView: MAPinAnnotationView, DJIFlightControllerDelegate {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var calloutView: CustomWaypointCalloutView?

    var section: MOSSection? = MOSSection()
    
    public typealias MOSGoActionBlock = (NSNumber, NSArray) -> Void
    var goAction: MOSGoActionBlock?
    
    var actionModel: MOSAction? = MOSAction()

    var connectedProduct: DJIBaseProduct? = nil
    var sentCmds: NSMutableDictionary? = NSMutableDictionary()
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("selected")
            
            if self.isSelected == selected {
                return
            }
            if selected {
                if self.calloutView == nil {
                    self.calloutView = CustomWaypointCalloutView.init(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
//                    self.calloutView?.center = CGPoint(x: self.bounds.width / 2 + self.calloutOffset.x, y: -((self.calloutView?.bounds.height)! / 2 + self.calloutOffset.y))
                    self.calloutView?.center = CGPoint(x: self.bounds.width / 2, y: 0)
                }
                self.calloutView?.setImage(image: UIImage(named: "calloutIcon")!)
                self.calloutView?.setTitle(title: self.annotation.title!)
                self.calloutView?.setSubTitle(subTitle: self.annotation.subtitle!)
                
                
                if self.goAction != nil {
                    
                    print("calloutView goAction is not nil")
                    
                    let cmdId: NSNumber? = self.actionModel?.cmdID
                    let arguments = NSArray()
                    
                    self.goAction!(cmdId!, arguments)
                }
                
                
                //            // Mobile Onboard communication
                self.addSubview(self.calloutView!)
            } else {
                self.calloutView?.removeFromSuperview()
            }
            
            super.setSelected(selected, animated: animated)
    }
    
    public func populateWithActionModel(actionModel: MOSAction) {
//        self.actionModel = actionModel
//        self.cmdIdLabel.text = actionModel.cmdID!.stringValue
//        self.commandLabel.text = actionModel.label
//        self.commandInformation.text = actionModel.information
//        self.commandResultLabel.text = ""
        print("populate action model")
        self.actionModel = actionModel
            self.calloutView?.setSubTitle(subTitle: actionModel.cmdID!.stringValue)
//        self.calloutView?.setSubTitle(subTitle: "\(actionModel.sensorData ?? 2)")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
