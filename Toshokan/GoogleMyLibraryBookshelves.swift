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
    let updated: TimeInterval?
    let created: TimeInterval?
    let volumeCount: Int
    let volumesLastUpdated:TimeInterval?
    let selfLink:URL
}

struct GoogleMyLibraryBookshelvesResponse {
    let  bookshelves:[Bookshelf]
    static let empty = GoogleMyLibraryBookshelvesResponse(bookshelves: [])
}

class GoogleMyLibraryBookshelves: GoogleAPI {
    private let path:String = "/books/v1/mylibrary/bookshelves"
    static let share = GoogleMyLibraryBookshelves()
    private var dateformatter:DateFormatter!
    private let bundle = Bundle.main
    
    private override init() {
        super.init()
        dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
    }
    
    private func getUrl() -> URL {
        let app_key:String! = {() -> String in
            if let plistPath = self.bundle.url(forResource: "GoogleService-Info", withExtension: "plist") {
                let values = NSDictionary(contentsOf: plistPath)! as! Dictionary<String, Any>
                let config = values.filter{key,value in key == "APP_KEY" }
                if config.isEmpty {
//                    APP_KEYがなかったら
                    return ""
                } else {
                  return config.first!.value as! String
                }
            } else {
//                plistがなかったら
                return ""
            }
        }()
        let query = "?key=\(app_key!)"
        return URL(string: GoogleBooksVolumes.HOST_NAME + path + query)!
    }
    
    func request() -> Observable<GoogleMyLibraryBookshelvesResponse> {
        let url = getUrl()
        var urlRequet = URLRequest(url: url)
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
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
    
    
    func request_normal() {
        let url = getUrl()
        var urlRequet = URLRequest(url: url)
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequet) { data, response, error in
            if let data = data, let response = response {
                print(response)
                do {
                    let json = JSON(data)
                    print(json)
                } catch  {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        task.resume()
    }

    
    func getBookshelf(item: JSON) -> Bookshelf {
        print(item)
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
        let volumeCount:Int = item["volumeCount"].intValue
        let selfLink:URL = URL(string: item["selfLink"].stringValue)!
        
        let volumesLastUpdated: TimeInterval? = getUnixtime(json: item["volumesLastUpdated"])
        let updated: TimeInterval? = getUnixtime(json: item["updated"])
        let created: TimeInterval? = getUnixtime(json: item["created"])
        return Bookshelf(id: id, title: title, description: description, access: access, updated: updated, created: created, volumeCount: volumeCount, volumesLastUpdated: volumesLastUpdated, selfLink: selfLink)
    }
    
    func getUnixtime(json:JSON) -> TimeInterval? {
        if json.stringValue.isEmpty {
            return nil
        }
        return dateformatter.date(from: json.stringValue)?.timeIntervalSince1970
    }
}
