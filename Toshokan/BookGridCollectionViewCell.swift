//
//  BookGridCollectionViewCell.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/14.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class BookGridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
    static let IDENTIFIRE = "bookGridCollectionCell"

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setVolume(volume: Volume) {
        var image = #imageLiteral(resourceName: "no_thumb_image")
        if let urlStr = volume.imagePaths[VolumeThumbnailType.thumbnail] {
            if let url = URL(string: urlStr) {
                do {
                    let imageData = try Data(contentsOf: url)
                    image =  UIImage(data: imageData)!
                } catch {
                }
            }
        }
        thumbnailView.image = image
    }

    static func className() -> String {
        //        TODO class名を返せるように
        return "BookGridCollectionViewCell"
    }

}
