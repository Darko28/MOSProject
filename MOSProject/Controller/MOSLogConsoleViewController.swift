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
        self.appDelegate?.model?.logChangedBlock = {
            self.updateLogView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLogView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLogView() {
        var fullLog = ""
        let logs: NSArray = self.appDelegate?.model?.logs as! NSArray
        for index in logs.count..<0 {
            let logEntry = logs[index] as! NSDictionary
            let timeStamp: NSDate = logEntry["timeStamp"] as! NSDate
            let log: String = logEntry["log"] as! String
            
            fullLog = "\(fullLog) + \(timeStamp) + \(log)"
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

