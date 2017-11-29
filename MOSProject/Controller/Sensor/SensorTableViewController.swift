//
//  SensorTableViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/11/29.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class SensorTableViewController: UITableViewController {
    
    
    var sensorDetailViewController: SensorDetailViewController?
    
    var listData = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        self.tableView.register(UINib(nibName: "SensorTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "sensor")
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.sensorDetailViewController = (controllers[controllers.count-1] as! SensorDetailViewController)
        }
        
        let dao = SensorDAO.sharedInstance
        self.listData = dao.findAll()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(_:)), name: Notification.Name(rawValue: "reloadViewNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = (self.splitViewController?.isCollapsed)!
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
////                let sensor = self.listData[indexPath.row] as! SensorDAO
//                let controller = (segue.destination as! UINavigationController).topViewController as! SensorDetailViewController
////                controller.detailItem = sensor
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
//    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensor", for: indexPath) as! SensorTableViewCell

        // Configure the cell...
        let sensor = self.listData[indexPath.row] as! Sensor
        cell.textLabel?.text = sensor.time.description
        cell.detailTextLabel?.text = "pm2.5: \(sensor.pm25Data)     pm10: \(sensor.pm10Data)"
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let sensor = self.listData[indexPath.row] as! Sensor
            let dao = SensorDAO.sharedInstance
            dao.remove(sensor)
            self.listData = dao.findAll()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    @objc func reloadView(_ notification: Notification) {
        let resList = notification.object as! NSMutableArray
        self.listData = resList
        self.tableView.reloadData()
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
