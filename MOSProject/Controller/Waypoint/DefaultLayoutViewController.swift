//
//  DefaultLayoutViewController.swift
//  DJIPlayback
//
//  Created by Darko on 2017/11/13.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import DJISDK
import DJIUILibrary
import VideoPreviewer

class DefaultLayoutViewController: DULDefaultLayoutViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        self.contentViewController = DJIRootViewController(nibName: "DJIRootViewController", bundle: Bundle.main)
        self.previewViewController = DULFPVViewController()
        print("previewController: \(self.previewViewController!)")
        
        print("leadingViewController widgets count: \(self.leadingViewController!.sideBarView!.widgets.count)")
        (self.leadingViewController!.sideBarView!.widgets.first!.widget as! DULTakeOffWidget).backgroundColor = UIColor.gray
        (self.leadingViewController!.sideBarView!.widgets.last!.widget as! DULReturnHomeWidget).backgroundColor = UIColor.gray
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
