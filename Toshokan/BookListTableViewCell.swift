//
//  BookListTableViewCell.swift
//  Toshokan
//
//  Created by jote on 2017/03/24.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {
    @IBOutlet weak var tumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    static let IDENTIFIRE = "bookListTableViewCell"
    
    func setVolume(volume: Volume) {
        
        titleLabel.text = convertShortStr(volume.title)
        descLabel.text = convertShortStr(volume.desc)

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
    
    func convertShortStr(_ str: String) -> String {
        if str.characters.count > 10 {
            let index = str.index(str.startIndex, offsetBy: 10)
            let shortTitle = str.substring(to: index)
            return shortTitle
        }
        return str
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
