//
//  CustomWaypointAnnotationView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/30.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit


let kCalloutWidth: CGFloat = 180.0
let kCalloutHeight: CGFloat = 64.0

class CustomWaypointAnnotationView: MAAnnotationView {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var calloutView: CustomWaypointCalloutView?

    var section: MOSSection? = MOSSection()
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("selected")
        if self.isSelected == selected {
            return
        }
        if selected {
            if self.calloutView == nil {
                self.calloutView = CustomWaypointCalloutView.init(frame: CGRect(x: 0, y: 0, width: kCalloutWidth, height: kCalloutHeight))
                self.calloutView?.center = CGPoint(x: self.bounds.width / 2 + self.calloutOffset.x, y: -((self.calloutView?.bounds.height)! / 2 + self.calloutOffset.y))
            }
            self.calloutView?.setImage(image: UIImage(named: "calloutIcon")!)
//            self.calloutView?.setTitle(title: self.annotation.title!)
            self.calloutView?.setSubTitle(subTitle: self.annotation.subtitle!)
            
//            // Mobile Onboard communication
////            let action: MOSAction? = self.section!.actions![indexPath.row]
//            let sensorData: Double = self.section!.actions?.last?.value(forKey: "sensorData") as! Double
//            
////            cell.populateWithActionModel(actionModel: action!)
//            self.calloutView?.setTitle(title: "\(sensorData)")
//            
//            cell.goAction = { [weak cell] (cmdId: NSNumber, arguments: NSArray) in
//                var cmdIdUInt = cmdId.uintValue
//                let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
//                
//                self.appDelegate?.model?.addLog(newLogEntry: "Sending CmdID \(cmdId) with \(arguments.count) Arguments")
//                cell!.commandResultLabel.text = "Sending ..."
//                print("\(cell!.commandResultLabel.text ?? "Sending ...")")
//                
//                self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
//                    self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
//                    cell?.commandResultLabel.text = "Command sent!"
//                }, and: { (data, error) in
//                    let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
//                    var ackValue: UInt16 = 0
//                    ackData.getBytes(&ackValue, length: UInt16.bitWidth)
//                    
//                    let responseMessage = "Ack: \(ackValue)"
//                    self.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
//                    
//                    cell?.commandResultLabel.text = responseMessage
//                })
//            }

            
//            self.appDelegate?.productCommunicationManager?.sendData(data: <#T##NSData#>, with: {
//                <#code#>
//            }, and: { (<#NSData#>, <#NSError?#>) in
//                <#code#>
//            })
            
            
            
            
            
            
            
            
            
            self.addSubview(self.calloutView!)
        } else {
            self.calloutView?.removeFromSuperview()
        }
        
        super.setSelected(selected, animated: animated)
    }
        
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
