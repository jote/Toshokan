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


private enum ParamKey {
    case query
    case volumeId
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
//        return loadSearchUrl(url: getUrl(params: [ParamKey.query: query]))
        let url = getUrl(params: [ParamKey.query: query])
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
    
    func find(id: String) -> Observable<GoogleBooksVolumesResponse> {
        let url = getUrl(params: [ParamKey.volumeId: id])
        let urlRequet = URLRequest(url: url)
        return URLSession.shared
            .rx.response(request: urlRequet)
            .retry(3)
            .map{ httpResponse, data -> GoogleBooksVolumesResponse in
                if httpResponse.statusCode == 404 {
                    return GoogleBooksVolumesResponse.init(volumes: [])
                }
                let json = JSON(data: data)
                let id = json["id"].stringValue
                let title = json["volumeInfo"]["title"].stringValue
                let desc = json["volumeInfo"]["description"].stringValue
                var imagePaths:Dictionary<VolumeThumbnailType, String> = [:]
                json["volumeInfo"]["imageLinks"].forEach { (key, json) in
                    if let thumbType = self.getVolumeThumbnailType(key: key) {
                        imagePaths[thumbType] = json.stringValue as String
                    }
                }
                let volume = Volume(id: id, title: title, desc: desc, imagePaths: imagePaths)
                return GoogleBooksVolumesResponse.init(volumes: [volume])
        }
    }

    private func getUrl(params: [ParamKey: String]) -> URL {
        var str: String = ""
        if let query = params[ParamKey.query] {
            let query_str = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            str = "?q=\(query_str)"
        } else if let volumeId = params[ParamKey.volumeId] {
            str = "/\(volumeId)"
        }
        return URL(string: GoogleBooksVolumes.HOST_NAME + path + str)!
    }
        
    
    private func getVolume(item: JSON) -> Volume {
        
        let title = item["volumeInfo"]["title"].stringValue
        let desc = item["volumeInfo"]["description"].stringValue
        let id = item["volumeInfo"]["id"].stringValue
        var imagePaths:Dictionary<VolumeThumbnailType, String> = [:]
        item["volumeInfo"]["imageLinks"].forEach { (key, json) in
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
