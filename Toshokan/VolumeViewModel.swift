//
//  VolumeViewModel.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/23.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation
import SwiftyJSON

class VolumeViewModel {
    public func getThought(volumeId: String) -> String {
        if let thoughts = ToshokanUserDefaultsModel.sharedUserInfo.getVolumeThoughts(){
            let json = JSON(parseJSON: thoughts)
            let targetThought = json[volumeId].stringValue
            return targetThought
        }
        return ""
    }
    
    public func setThought(volumeId: String, thought: String) {
        var json:JSON!
        if let thoughts = ToshokanUserDefaultsModel.sharedUserInfo.getVolumeThoughts(){
            json = JSON(parseJSON: thoughts)
           json[volumeId].string = thought
        } else {
            json = JSON([volumeId: thought])
        }
        let jsonStr = json.rawString([writtingOptionsKeys.castNilToNSNull : false])
        ToshokanUserDefaultsModel.sharedUserInfo.setVolumeThoughts(thoughts: jsonStr!)
    }
    
    public func getVolumeStatus(volumeId: String) -> VolumeStatus {
        if let statusStr = ToshokanUserDefaultsModel.sharedUserInfo.getVolumeStatus(){
            let json = JSON(parseJSON: statusStr)
            return convertStatus(str: json[volumeId].stringValue)
        }
        //statusがない時
        return VolumeStatus.toRead
    }
    
    private func convertStatus(str: String) -> VolumeStatus {
        switch str {
        case VolumeStatus.haveRead.rawValue:
            return VolumeStatus.haveRead
        case VolumeStatus.reading.rawValue:
            return VolumeStatus.reading
        case VolumeStatus.toRead.rawValue:
            return VolumeStatus.toRead
        default:
            return VolumeStatus.toRead
        }
    }

}