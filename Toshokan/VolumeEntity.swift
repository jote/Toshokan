//
//  VolumeEntity.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation

struct Volume {
    let id: String
    let title: String
    let desc: String
    let imagePaths: Dictionary<VolumeThumbnailType, String>
}

enum VolumeThumbnailType: String {
    case smallThumbnail = "smallThumbnail"
    case thumbnail = "thumbnail"
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
}

enum VolumeStatus: String {
    case toRead = "toRead"
    case reading = "reading"
    case haveRead = "haveRead"
}
