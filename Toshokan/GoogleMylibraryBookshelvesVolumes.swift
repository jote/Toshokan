//
//  GoogleMylibraryBookshelvesVolumes.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct GoogleMylibraryBookshelvesVolumesResponse {
    let volumes:[Volume]
    static let empty = GoogleMylibraryBookshelvesVolumesResponse(volumes: [])
}

class GoogleMylibraryBookshelvesVolumes: GoogleAPI{
    static let share = GoogleMylibraryBookshelvesVolumes()
    private let bundle = Bundle.main
    
    private func getUrl(shelfId: Int) -> URL {
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
        let path = String(format: "/books/v1/mylibrary/bookshelves/%@/volumes?key=%@", String(shelfId), app_key!)
        let urlStr = GoogleMylibraryBookshelvesVolumes.HOST_NAME + path
        return URL(string: urlStr)!
    }
    
    func request(shelfId: Int) -> Observable<GoogleMylibraryBookshelvesVolumesResponse> {
        let url = getUrl(shelfId: shelfId)
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(GoogleUserModel.share.accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.rx.response(request: urlRequest)
            .retry(3)
            .map{ httpResponse, data -> GoogleMylibraryBookshelvesVolumesResponse in
                if httpResponse.statusCode == 404 {
                    return GoogleMylibraryBookshelvesVolumesResponse.empty
                }
                let json = JSON(data)
                let volumes = json["items"].map({ (value) -> Volume in
                    self.getVolume(value.1)
                })
                return GoogleMylibraryBookshelvesVolumesResponse(volumes: volumes)
        }
    }
    
    private func getVolume(_ json: JSON) -> Volume {
        let id:String = json["id"].stringValue
        let title:String = json["volumeInfo"]["title"].stringValue
        let desc:String = json["volumeInfo"]["description"].stringValue
        var imagePaths: [VolumeThumbnailType: String] = [:]
        json["volumeInfo"]["imageLinks"].forEach { (key, json) in
            if let thumbType = self.getVolumeThumbnailType(key: key) {
                imagePaths[thumbType] = json.stringValue as String
            }
        }
        return Volume(id: id, title: title, desc: desc, imagePaths: imagePaths)
    }

    private func getVolumeThumbnailType(key: String) -> VolumeThumbnailType? {
        switch key {
        case VolumeThumbnailType.small.rawValue:
            return VolumeThumbnailType.small
        case VolumeThumbnailType.smallThumbnail.rawValue:
            return VolumeThumbnailType.smallThumbnail
        case VolumeThumbnailType.medium.rawValue:
            return VolumeThumbnailType.medium
        case VolumeThumbnailType.large.rawValue:
            return VolumeThumbnailType.large
        case VolumeThumbnailType.extraLarge.rawValue:
            return VolumeThumbnailType.extraLarge
        case VolumeThumbnailType.small.rawValue:
            return VolumeThumbnailType.small
        case VolumeThumbnailType.small.rawValue:
            return VolumeThumbnailType.small
        case VolumeThumbnailType.thumbnail.rawValue:
            return VolumeThumbnailType.thumbnail
        default :
            return nil
        }
    }

}
