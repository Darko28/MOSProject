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
        
        let backBarBtn: UIBarButtonItem = UIBarButtonItem.init(title: "back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToDefaultLayoutVC))
        self.navigationItem.leftBarButtonItem = backBarBtn

        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let viewControllers = NSMutableArray()
//        var selectedViewController: MOSJSONDynamicController? = nil
        let allSections = self.appDelegate!.model!.jsonSections
        
//        // add two table view tab
//        for index in 0..<allSections!.count {
//            let section = allSections![index]
//            let newController: MOSJSONDynamicController = MOSJSONDynamicController(style: .plain)
//            newController.section = section
//
//            if selectedViewController == nil {
//                selectedViewController = newController
//            }
//
//            newController.tabBarItem = UITabBarItem(title: section.name, image: UIImage(named: "first"), tag: index)
//            newController.title = section.name
//
//            viewControllers.add(newController)
//        }
//
        let index = allSections!.count - 1
//
//        // Add the advanced view
//        let lsAdv = AdvancedViewController(nibName: "AdvancedViewController", bundle: Bundle.main)
//        lsAdv.tabBarItem = UITabBarItem(title: "Advanced", image: UIImage(named: "second"), tag: index + 1)
//        lsAdv.title = "Advanced"
//        viewControllers.add(lsAdv)
        
        // Add the log view
        let logVC = MOSLogConsoleViewController(nibName: "MOSLogConsoleViewController", bundle: Bundle.main)
        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(named: "second"), tag: index + 1)
        logVC.title = "Logs"
        viewControllers.add(logVC)
        
        let waypointVC = DJIRootViewController(nibName: "DJIRootViewController", bundle: Bundle.main)
        waypointVC.tabBarItem = UITabBarItem(title: "Waypoint", image: UIImage(named: "three"), tag: index + 1)
        waypointVC.title = "Waypoint"
//        waypointVC.navigationController?.navigationBar.isHidden = true
        viewControllers.add(waypointVC)
        
//        let sensorTableVC = SensorTableViewController(nibName: "SensorTableViewController", bundle: Bundle.main)
        let sensorTableVC: SensorTableViewController = SensorTableViewController(style: .plain)
        sensorTableVC.tabBarItem = UITabBarItem(title: "SensorData", image: UIImage(named: "four"), tag: index + 1)
        sensorTableVC.title = "Sensors"
        viewControllers.add(sensorTableVC)
        
//        let defaultVC: DefaultLayoutViewController = DefaultLayoutViewController(nibName: "DefaultLayoutViewController", bundle: Bundle.main)
//        defaultVC.title = "Default"
//        viewControllers.add(defaultVC)
        
        
        self.appDelegate?.model?.addLog(newLogEntry: "Created UI")
        self.setViewControllers(viewControllers as? [UIViewController], animated: true)
        self.selectedViewController = viewControllers[2] as? UIViewController
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToDefaultLayoutVC))
    }
    
    @objc func backToDefaultLayoutVC() {
        self.dismiss(animated: true, completion: nil)
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
