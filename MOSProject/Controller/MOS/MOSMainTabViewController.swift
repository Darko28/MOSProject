//
//  MOSMainTabViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK

class MOSMainTabViewController: UITabBarController {
    
    var appDelegate: AppDelegate?

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let viewControllers = NSMutableArray()
        var selectedViewController: MOSJSONDynamicController? = nil
        var allSections = self.appDelegate!.model!.jsonSections
        
        for index in 0..<allSections!.count {
            let section = allSections![index]
            let newController: MOSJSONDynamicController = MOSJSONDynamicController(style: .plain)
            newController.section = section
            
            if selectedViewController == nil {
                selectedViewController = newController
            }
            
            newController.tabBarItem = UITabBarItem(title: section.name, image: UIImage(named: "first"), tag: index)
            newController.title = section.name
            
            viewControllers.add(newController)
        }

        let index = allSections!.count - 1
        
        // Add the advanced view
        let lsAdv = AdvancedViewController(nibName: "AdvancedViewController", bundle: Bundle.main)
        lsAdv.tabBarItem = UITabBarItem(title: "Advanced", image: UIImage(named: "second"), tag: index + 1)
        lsAdv.title = "Advanced"
        viewControllers.add(lsAdv)
        
        // Add the log view
        let logVC = MOSLogConsoleViewController(nibName: "MOSLogConsoleViewController", bundle: Bundle.main)
        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(named: "second"), tag: index + 1)
        logVC.title = "Logs"
        viewControllers.add(logVC)
        
        let waypointVC = DJIRootViewController(nibName: "DJIRootViewController", bundle: Bundle.main)
        waypointVC.tabBarItem = UITabBarItem(title: "Waypoint", image: UIImage(named: "three"), tag: index + 1)
        waypointVC.title = "Waypoint"
        viewControllers.add(waypointVC)
        
        self.appDelegate?.model?.addLog(newLogEntry: "Created UI")
        self.setViewControllers(viewControllers as? [UIViewController], animated: true)
        self.selectedViewController = selectedViewController
        
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
