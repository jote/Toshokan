//
//  ShelvesTableViewCell.swift
//  Toshokan
//
//  Created by konomi_ban on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class ShelvesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var _shelfId:Int!
    var shelfId:Int {
        set {
            _shelfId = newValue
        }
        get {
            return _shelfId
        }
    }
    
    var title: String {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text!
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
