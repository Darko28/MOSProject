//
//  AdvancedViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class AdvancedViewController: UIViewController {
    
    var appDelegate: AppDelegate? //= UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var lidarLoggingSwitch: UISwitch!
    @IBOutlet weak var collisionAvoidanceSwitch: UISwitch!
    @IBOutlet weak var trajectoryLidarMappingSwitch: UISwitch!
    @IBOutlet weak var trajectoryCollisionAvoidanceSwitch: UISwitch!
    @IBOutlet weak var commandResultLabel: UILabel!
    
    @IBAction func lidarLoggingGo(sender: AnyObject) {
        let cmdID: UInt8 = self.lidarLoggingSwitch.isOn ? 0x14 : 0x15
        self.go(cmdId: cmdID)
    }
    
    @IBAction func collisionAvoidanceGo(sender: AnyObject) {
        let cmdID: UInt8 = self.collisionAvoidanceSwitch.isOn ? 0x16 : 0x17
        self.go(cmdId: cmdID)
    }
    
    @IBAction func trajectoryGo(sender: AnyObject) {
        var cmdId: UInt8 = 0
        if (!self.trajectoryLidarMappingSwitch.isOn && !self.trajectoryCollisionAvoidanceSwitch.isOn) { cmdId=0x18 }
        else if (!self.trajectoryLidarMappingSwitch.isOn && self.trajectoryCollisionAvoidanceSwitch.isOn) { cmdId=0x19 }
        else if (self.trajectoryLidarMappingSwitch.isOn && !self.trajectoryCollisionAvoidanceSwitch.isOn) { cmdId=0x1A }
        else if (self.trajectoryLidarMappingSwitch.isOn && self.trajectoryCollisionAvoidanceSwitch.isOn) { cmdId=0x1B }
        self.go(cmdId: cmdId)
    }
    
    public func go(cmdId: UInt8) {
        var mutableCmdId = cmdId
        let data: Data = Data(bytes: &mutableCmdId, count: 1)
        self.appDelegate?.model?.addLog(newLogEntry: "Sending CmdID \(cmdId)")
        self.commandResultLabel.text = "Sending..."
        
        self.appDelegate?.productCommunicationManager?.sendData(data: data as NSData, with: { [weak self] in
            self?.appDelegate?.model?.addLog(newLogEntry: "Sending CmdID \(cmdId)")
            self?.commandResultLabel.text = "Command Sent!"
        }, and: { [weak self] (data: NSData, error: NSError?) in
            let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
            var ackValue: UInt16 = 0
            ackData.getBytes(&ackValue, length: UInt16.bitWidth)
            
            let responseMessage: String = "Ack: \(ackValue)"
            self?.appDelegate?.model?.addLog(newLogEntry: "Received ACK \(ackValue) for CmdID \(mutableCmdId)")
            
            self?.commandResultLabel.text = responseMessage
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
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
