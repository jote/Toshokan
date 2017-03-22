//
//  BookshelfEntity.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation

/// 本棚の公開状態
///
/// - publicStatus: 公開
/// - privateStatus: 非公開
enum BookshelfAccessStatus: String {
    case publicStatus = "PRIVATE"
    case privateStatus = "PUBLIC"
}

/// 本棚報
struct Bookshelf {
    let id:Int
    let title:String
    let description: String
    let access: BookshelfAccessStatus
    let updated: TimeInterval?
    let created: TimeInterval?
    let volumeCount: Int
    let volumesLastUpdated:TimeInterval?
    let selfLink:URL
}
