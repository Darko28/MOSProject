//
//  MOSJSONDynamicViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class MOSJSONDynamicController: UITableViewController {
    
    var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    var section: MOSSection? = MOSSection()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        self.tableView.register(UINib(nibName: "MOSDynamicTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "action")
        self.tableView.estimatedRowHeight = 40
        
        let currentEdgeInset: UIEdgeInsets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsetsMake(20, currentEdgeInset.left, 50, currentEdgeInset.right)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.section!.actions!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MOSDynamicTableViewCell = tableView.dequeueReusableCell(withIdentifier: "action", for: indexPath) as! MOSDynamicTableViewCell
        let action: MOSAction? = self.section!.actions![indexPath.row]
        
        cell.populateWithActionModel(actionModel: action!)
        
        cell.goAction = { [weak cell] (cmdId: NSNumber, arguments: NSArray) in
            var cmdIdUInt = cmdId.uintValue
            let data: NSData = NSData(bytes: &cmdIdUInt, length: cmdIdUInt.bitWidth)
            
            self.appDelegate?.model?.addLog(newLogEntry: "Sending CmdID \(cmdId) with \(arguments.count) Arguments")
            cell!.commandResultLabel.text = "Sending ..."
            print("\(cell!.commandResultLabel.text ?? "Send")")
            
            self.appDelegate?.productCommunicationManager?.sendData(data: data, with: {
                self.appDelegate?.model?.addLog(newLogEntry: "Sent CmdID \(cmdId)")
                cell?.commandResultLabel.text = "Command sent!"
            }, and: { (data, error) in
                let ackData: NSData = data.subdata(with: NSMakeRange(2, data.length - 2)) as NSData
                var ackValue: UInt16 = 0
                ackData.getBytes(&ackValue, length: UInt16.bitWidth)
                
                let responseMessage = "Ack \(ackValue)"
                self.appDelegate?.model?.addLog(newLogEntry: "Received ACK [\(responseMessage)] for CmdID \(cmdId)")
                
                cell?.commandResultLabel.text = responseMessage
            })
        }

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
