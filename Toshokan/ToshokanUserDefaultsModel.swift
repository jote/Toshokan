//
//  ToshokanConfigModel.swift
//  Toshokan
//
//  Created by jote on 2017/03/02.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation

enum ToshokanUserDefaultsKey: String {
    case hasAgreement = "hasAgreement"
    case searchResultViewType = "searchResultViewType"
    case googleUserInfo = "googleUserInfo"
    case volumeThoughts = "volumeThought"
    case volumeStatus = "volumeStatus"
}

/// Toshokan App 独自のUserDefaultを操作
class ToshokanUserDefaultsModel {
    public static  var sharedUserInfo = ToshokanUserDefaultsModel.init()
    private static var userInfo: Dictionary<String, Any>!
    private let userDefaults = UserDefaults()

    
    /// Toshokan Appの利用規約に了承しているかどうか
    public var hasAgreement: Bool {
        set {
            self.userDefaults.set(true, forKey: ToshokanUserDefaultsKey.hasAgreement.rawValue)
        }
        get {
            return self.userDefaults.bool(forKey: ToshokanUserDefaultsKey.hasAgreement.rawValue)
        }
    }
    
    private init() {
    }
    
    
    /// GoogleUser 情報をJSONの文字列として返す
    /// 呼び出し側でJSONをパースして利用
    ///
    /// - Returns: JSON文字列
    public func getGoogleUserInfo() ->  String? {
        return userDefaults.string(forKey: ToshokanUserDefaultsKey.googleUserInfo.rawValue)
    }
    
    
    /// GoogleUser 情報をJSONの文字列にして UserDefaultsに保存する
    ///
    /// - Parameter userInfo: Stringで中身はJSON
    public func saveGoogleUserInfo(userInfo: String) {
        userDefaults.set(userInfo, forKey: ToshokanUserDefaultsKey.googleUserInfo.rawValue)
    }
    
    public func getVolumeThoughts() -> String? {
        return userDefaults.string(forKey: ToshokanUserDefaultsKey.volumeThoughts.rawValue)
    }
    
    public func setVolumeThoughts(thoughts: String) {
        userDefaults.set(thoughts, forKey: ToshokanUserDefaultsKey.volumeThoughts.rawValue)
    }

    public func getVolumeStatus() -> String? {
        return userDefaults.string(forKey: ToshokanUserDefaultsKey.volumeStatus.rawValue)
    }
    
    public func setVolumeStatus(thoughts: String) {
        userDefaults.set(thoughts, forKey: ToshokanUserDefaultsKey.volumeStatus.rawValue)
    }
}
