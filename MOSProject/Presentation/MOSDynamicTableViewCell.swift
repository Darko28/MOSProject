//
//  MOSDynamicTableViewCell.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

class MOSDynamicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commandLabel: UILabel!
    @IBOutlet weak var commandInformation: UILabel!
    @IBOutlet weak var cmdIdLabel: UILabel!
    @IBOutlet weak var commandResultLabel: UILabel!
    
    public typealias MOSGoActionBlock = (NSNumber, NSArray) -> Void
    var goAction: MOSGoActionBlock?
    
    var actionModel: MOSAction?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func go(sender: AnyObject) {
        if self.goAction != nil {
            let cmdId: NSNumber? = self.actionModel?.cmdID
            let arguments = NSArray()
            
            self.goAction!(cmdId!, arguments)
        }
    }
    
    public func populateWithActionModel(actionModel: MOSAction) {
        self.actionModel = actionModel
        self.cmdIdLabel.text = "\(actionModel.cmdID ?? 0)"
        self.commandLabel.text = actionModel.label
        self.commandLabel.text = actionModel.information
        self.commandResultLabel.text = ""
    }
    
}
