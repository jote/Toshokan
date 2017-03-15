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
    static let IDENTIFIRE = "bookListCollectionCell"
    
    func setVolume(volume: Volume) {
        titleLabel.text = volume.title
        descLabel.text = volume.title
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
        tumbnailView.image = image
    }
    
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
    
    static func className() -> String {
//        TODO class名を返せるように
        return "BookListCollectionViewCell"
    }
}
