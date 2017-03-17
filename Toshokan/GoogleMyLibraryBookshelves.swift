//
//  GoogleMyLibraryBookshelves.swift
//  Toshokan
//
//  Created by jote on 2017/03/17.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

enum BookshelfAccessStatus: String {
    case publicStatus = "PRIVATE"
    case privateStatus = "PUBLIC"
}

struct Bookshelf {
    let id:Int
    let title:String
    let description: String
    let access: BookshelfAccessStatus
    let updated: TimeInterval
    let created: TimeInterval
    let volumeCount: Int
    let volumesLastUpdated:TimeInterval
    let selfLink:URL
}

struct GoogleMyLibraryBookshelvesResponse {
    let  bookshelves:[Bookshelf]
}

class GoogleMyLibraryBookshelves: GoogleAPI {
    let path:String = "/books/v1/mylibrary/bookshelves"
    let share = GoogleMyLibraryBookshelves()
    var dateformatter:DateFormatter!
    
    override init() {
        super.init()
        dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
    }
    
    func getUrl() -> URL {
        let api_key = ""
        let query = "?key=\(api_key)"
        return URL(string: GoogleBooksVolumes.HOST_NAME + path + query)!
    }
    
    func request() -> Observable<GoogleMyLibraryBookshelvesResponse> {
        let url = getUrl()
        let urlRequet = URLRequest(url: url)
        return URLSession.shared.rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> GoogleMyLibraryBookshelvesResponse in
                if httpResponse.statusCode == 404 {
                    return GoogleMyLibraryBookshelvesResponse.init(bookshelves: [])
                }
                let json = JSON(data: data)
                let bookshelves:[Bookshelf] = json["items"].map({ (k_, item) -> Bookshelf in
                    self.getBookshelf(item: item)
                })
                return GoogleMyLibraryBookshelvesResponse.init(bookshelves: bookshelves)
        }
    }
    
    func getBookshelf(item: JSON) -> Bookshelf {
        let id:Int =  item["id"].intValue
        let title:String = item["title"].stringValue
        let description:String = item["description"].stringValue
        let access:BookshelfAccessStatus = {() -> BookshelfAccessStatus in
            if item["access"].stringValue == BookshelfAccessStatus.privateStatus.rawValue {
                return BookshelfAccessStatus.privateStatus
            }else {
                return BookshelfAccessStatus.publicStatus
            }
        }()
        let updated:TimeInterval = dateformatter.date(from: item["update"].stringValue)!.timeIntervalSince1970
        let created:TimeInterval = dateformatter.date(from: item["created"].stringValue)!.timeIntervalSince1970
        let volumeCount:Int = item["volumeCount"].intValue
        let volumesLastUpdated:TimeInterval = dateformatter.date(from: item["volumesLastUpdated"].stringValue)!.timeIntervalSince1970
        let selfLink:URL = URL(string: item["selfLink"].stringValue)!
        return Bookshelf(id: id, title: title, description: description, access: access, updated: updated, created: created, volumeCount: volumeCount, volumesLastUpdated: volumesLastUpdated, selfLink: selfLink)
    }
}
