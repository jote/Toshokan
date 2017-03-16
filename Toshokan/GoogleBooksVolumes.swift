//
//  GoogleBooksVolumes.swift
//  Toshokan
//
//  Created by jote on 2017/03/07.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxCocoa
import RxSwift


struct Volume {
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

struct GoogleBooksVolumesResponse {
    let volumes: [Volume]
    static let empty = GoogleBooksVolumesResponse(volumes: [])
}


class GoogleBooksVolumes : GoogleAPI {
    let path:String = "/books/v1/volumes"
    static let sharedAPI = GoogleBooksVolumes()
}



extension GoogleBooksVolumes {
    func search(query: String) -> Observable<GoogleBooksVolumesResponse> {
        return loadSearchUrl(url: getUrl(query: query))
    }

    func getUrl(query: String) -> URL {
        let query_str = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let str = "?q=\(query_str)"
        return URL(string: GoogleBooksVolumes.HOST_NAME + path + str)!
    }
    
    private func loadSearchUrl(url: URL) -> Observable<GoogleBooksVolumesResponse> {
        let urlRequet = URLRequest(url: url)
        return URLSession.shared
            .rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> GoogleBooksVolumesResponse in
                if httpResponse.statusCode == 404 {
                    return GoogleBooksVolumesResponse.init(volumes: [])
                }
                let json = JSON(data: data)
                let items = json["items"]
                let volumes = items.map{ self.getVolume(item: $0.1) }
                return GoogleBooksVolumesResponse.init(volumes: volumes)
            }
    }

    
    
    private func getVolume(item: JSON) -> Volume {
        
        let title = item["volumeInfo"]["title"].stringValue
        let desc = item["volumeInfo"]["title"].stringValue
        var imagePaths:Dictionary<VolumeThumbnailType, String> = [:]
        item["volumeInfo"]["imageLinks"].forEach { (key, json) in
            if let thumbType = self.getVolumeThumbnailType(key: key) {
                imagePaths[thumbType] = json.stringValue as String
            }
        }
        return Volume(title: title, desc: desc, imagePaths: imagePaths)
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
