//
//  MOSLogConsoleViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class MOSLogConsoleViewController: UIViewController {
    
    var appDelegate: AppDelegate?
    @IBOutlet weak var logView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
//        self.appDelegate?.model?.logChangedBlock = {
//            self.updateLogView()
//        }
        self.appDelegate?.model?.logChangedBlock = self.updateLogView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLogView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func updateLogView() {
//        var fullLog = ""
//        let logs: NSArray = (self.appDelegate!.model!.logs)! as NSArray
//        for index in (0..<logs.count-1).reversed() {
//            let logEntry = logs[index] as! NSDictionary
//            let logEntry2 = logs[index+1] as! NSDictionary
//            let timeStamp: Date = logEntry["timestamp"] as! Date
//            let log: String = logEntry2["log"] as! String
//
//            fullLog = "\(fullLog) + \(timeStamp) + \(log)"
//        }
//        self.logView.text = fullLog
//    }

    func updateLogView() {
        var fullLog = ""
        let logs: Array<Dictionary<String, Any>> = (self.appDelegate!.model!.logs)! as Array<Dictionary<String, Any>>
        for logEntry in logs.enumerated() {
            var timeStamp: Date = Date()
            var log: String = ""
            
            if logEntry.offset % 2 == 0 {
                timeStamp = logEntry.element["timestamp"] as! Date
            } else {
                log = logEntry.element["log"] as! String
           }
            if logEntry.offset % 2 == 1 {
                fullLog = "\(fullLog) + \(timeStamp) +\(log)\n"
            }
        }
        self.logView.text = fullLog
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinvarvariewController.
        // Pass the selected object to the new view controller.
    }
    */

}

