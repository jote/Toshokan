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



/// リクエストパラメータを列挙
///
/// - volumePosition: 本の位置
/// - volumeId: 本のID
private enum ParamsKey: String {
    case volumePosition = "volumePosition"
    case volumeId = "volumeId"
}

/// リクエストできるメソッドを列挙
///
/// - addVolume: 本を追加
/// - moveVolume: 本を移動
/// - removeVolume: 本を消す
private enum MethodType {
    case addVolume
    case moveVolume
    case removeVolume
}

/// APIレスポンスの情報を入れる
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
    
    
    /// Bookshelf をArrayで複数得られるメソッド
    /// GoogleMyLibraryBookshelvesResponse.bookshelvesとして情報を得られる
    ///
    /// - Returns: GoogleMyLibraryBookshelvesResponse
    func listRequest() -> Observable<GoogleMyLibraryBookshelvesResponse> {
        let url = getUrl(params: [:])
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
    
    /// 指定された Bookshelf 1つ入れた配列を得られるメソッド
    /// GoogleMyLibraryBookshelvesResponse.bookshelvesとして情報を得られる
    ///
    /// - Parameter shelfId: Int
    /// - Returns: GoogleMyLibraryBookshelvesResponse
    func getRequest(shelfId: Int) -> Observable<GoogleMyLibraryBookshelvesResponse> {
        let url = getUrl(params: [:], shelfId: shelfId)
        var urlRequet = URLRequest(url: url)
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> GoogleMyLibraryBookshelvesResponse in
                if httpResponse.statusCode == 404 {
                    return GoogleMyLibraryBookshelvesResponse.init(bookshelves: [])
                }
                let json = JSON(data: data)
                let bookShelf = self.getBookshelf(item: json)
                return GoogleMyLibraryBookshelvesResponse.init(bookshelves: [bookShelf])
        }
    }
    
    /// 指定された本棚に指定した本を追加
    ///
    /// - Parameters:
    ///   - volumeId: 本ID
    ///   - shelfId: 本棚ID
    /// - Returns: リクエストが成功したかどうかのBool
    func addVolumeRequest(volumeId: String, shelfId: Int) -> Observable<Bool>{
        let params = [ParamsKey.volumeId: volumeId]
        let url = getUrl(params: params, shelfId: shelfId, methodType: MethodType.addVolume)
        var urlRequet = URLRequest(url: url)
        urlRequet.httpMethod = "POST"
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> Bool in
                if httpResponse.statusCode != 204 {
                    print("Request failed. http status: \(httpResponse.statusCode)")
                    return false
                }
                return true
        }
    }

    /// 指定された本棚の指定された並び順で本を移動
    ///
    /// - Parameters:
    ///   - volumeId: 本ID
    ///   - shelfId: 本棚ID
    ///   - volumePosition: 本の並び順
    /// - Returns: リクエストが成功したかどうかのBool
    func moveVolumeRequest(volumeId: String, shelfId: Int, volumePosition: Int)  -> Observable<Bool> {
        let params = [ParamsKey.volumeId: volumeId, ParamsKey.volumePosition: String(volumePosition)]
        let url = getUrl(params: params, shelfId: shelfId, methodType: MethodType.moveVolume)
        var urlRequet = URLRequest(url: url)
        urlRequet.httpMethod = "POST"
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> Bool in
                if httpResponse.statusCode != 204 {
                    print("Request failed. http status: \(httpResponse.statusCode)")
                    return false
                }
                return true
        }
    }
    
    
    /// 指定された本棚から指定した本を消す
    ///
    /// - Parameters:
    ///   - volumeId: 本ID
    ///   - shelfId: 本棚ID
    /// - Returns: リクエストが成功したかどうかのBool
    func removeVolumeRequest(volumeId: String, shelfId: Int) -> Observable<Bool>  {
        let params = [ParamsKey.volumeId: volumeId]
        let url = getUrl(params: params, shelfId: shelfId, methodType: MethodType.removeVolume)
        var urlRequet = URLRequest(url: url)
        urlRequet.httpMethod = "POST"
        urlRequet.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> Bool in
                if httpResponse.statusCode != 204 {
                    print("Request failed. http status: \(httpResponse.statusCode)")
                    return false
                }
                return true
        }

    }
    
    
    /// GoogleMyLibraryBookshelves APIのURLを返す
    /// Google APP_KEYは GoogleService-Info.plistに設定されているものを利用する
    ///
    /// - Parameter params: ParamsKeyでリクエストできるパラメータを指定する
    /// - Returns: URL
    private func getUrl(params: [ParamsKey: String], shelfId: Int? = nil , methodType: MethodType? = nil) -> URL {
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
        var query:String = ""
        if shelfId != nil {
            query = query + "/\(shelfId!)"
            if methodType == MethodType.addVolume {
                query = query + "/addVolume"
            } else if methodType == MethodType.moveVolume {
                query = query + "/moveVolume"
            } else if methodType == MethodType.removeVolume {
                query = query + "/removeVolume"
            }
        }
        let paramStr = params.map { (param) -> String in
            "\(param.key)=\(param.value)"
        }
        query = query + "?" + paramStr.joined(separator: "&") + "&key=\(app_key!)"
        return URL(string: GoogleBooksVolumes.HOST_NAME + path + query)!
    }
    

    func request_normal() {
        let url = getUrl(params: [:])
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

    
    /// APIレスポンスのitemsから Bookshelf にオブジェクト化したものを返す
    ///
    /// - Parameter item: JSON
    /// - Returns: Bookshelf
    private func getBookshelf(item: JSON) -> Bookshelf {
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
    
    
    /// 日時情報は UnixTime に変換する
    ///
    /// - Parameter json: 日時情報の文字列
    /// - Returns: TimeInterval or nil
    private func getUnixtime(json:JSON) -> TimeInterval? {
        if json.stringValue.isEmpty {
            return nil
        }
        return dateformatter.date(from: json.stringValue)?.timeIntervalSince1970
    }
}
