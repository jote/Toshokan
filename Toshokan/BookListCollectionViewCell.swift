//
//  BookListCollectionViewCell.swift
//  Toshokan
//
//  Created by konomi_ban on 2017/03/06.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class BookListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getThumbnailWidth() -> CGFloat {
        return tumbnailView.frame.size.width
    }

    func getThumbnailHeight() -> CGFloat {
        return tumbnailView.frame.size.height
    }

}
