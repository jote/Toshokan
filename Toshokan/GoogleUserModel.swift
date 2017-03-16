//
//  GoogleUserModel.swift
//  Toshokan
//
//  Created by jote on 2017/03/16.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation
import SwiftyJSON


/// GIDGoogleUser, GIDAuthentication, GIDProfileData のインターフェース名を列挙型にして保存
///
/// - userId: GIDGoogleUser.userID の値を入れたkey
/// - name: GIDProfileData.name の値を入れたkey
/// - accessToken: GIDAuthentication.accessToken の値を入れたkey
/// - accessTokenExpirationDate: GIDAuthentication.accessTokenExpirationDate の値を入れたkey
/// - refreshToken: GIDAuthentication.refreshToken の値を入れたkey
/// - idToken: GIDAuthentication.idToken の値を入れたkey
/// - idTokenExpirationDate: GIDAuthentication.idTokenExpirationDate の値を入れたkey
enum GoogleUserInfoKey: String {
    case userId = "userID"
    case name = "name"
    case accessToken = "accessToken"
    case accessTokenExpirationDate = "accessTokenExpirationDate"
    case refreshToken = "refreshToken"
    case idToken = "idToken"
    case idTokenExpirationDate = "idTokenExpirationDate"
}


/// Googleの認証情報を UserDefaults に保存するためのインターフェース
class GoogleUserModel {
    static let share = GoogleUserModel.init()
    var userInfo: Dictionary<GoogleUserInfoKey, String> = [:]

    
    /// GIDGoogleUser.userID の値
    var userId: String {
        set {
            self.userInfo[GoogleUserInfoKey.userId] = newValue
        }
        get {
            if let id = self.userInfo[GoogleUserInfoKey.userId] {
                return id
            } else {
                return ""
            }
        }
    }
    
    /// GIDProfileData.name の値
    var name: String {
        set {
            self.userInfo[GoogleUserInfoKey.name] = newValue
        }
        get {
            if let v = self.userInfo[GoogleUserInfoKey.name] {
                return v
            } else {
                return ""
            }
        }
    }
    
    /// accessToken: GIDAuthentication.accessToken の値
    var accessToken: String {
        set {
            self.userInfo[GoogleUserInfoKey.accessToken] = newValue
        }
        get {
            if let v = self.userInfo[GoogleUserInfoKey.accessToken] {
                return v 
            } else {
                return ""
            }
        }
    }
    
    /// refreshToken: GIDAuthentication.refreshToken の値
    var refreshToken: String {
        set {
            self.userInfo[GoogleUserInfoKey.refreshToken] = newValue
        }
        get {
            if let v = self.userInfo[GoogleUserInfoKey.refreshToken] {
                return v 
            } else {
                return ""
            }
        }
    }
    
    /// idToken: GIDAuthentication.idToken の値
    var idToken: String {
        set {
            self.userInfo[GoogleUserInfoKey.idToken] = newValue
        }
        get {
            if let v = self.userInfo[GoogleUserInfoKey.idToken] {
                return v 
            } else {
                return ""
            }
        }
    }
    
    /// shareからsingletonで利用するためprivate
    private init() {
        if let userInfoStr = ToshokanUserDefaultsModel.sharedUserInfo.getGoogleUserInfo() {
            JSON(parseJSON: userInfoStr).forEach({ value in
                if let GoogleUserInfoKey = convertGoogleUserInfoKey(value.0) {
                    self.userInfo[GoogleUserInfoKey] = value.1.stringValue
                }
            })
        }
    }
    
    /// UserDefaultsではユーザ情報のキーが文字列で保存されているので、GoogleUserInfoKey に変換する
    ///
    /// - Parameter str: UserDefaultsにあるユーザ情報のキー
    /// - Returns: GoogleUserInfoKey
    private func convertGoogleUserInfoKey(_ str: String) -> GoogleUserInfoKey? {
        switch str {
        case GoogleUserInfoKey.userId.rawValue:
            return GoogleUserInfoKey.userId
        case GoogleUserInfoKey.name.rawValue:
            return GoogleUserInfoKey.name
        case GoogleUserInfoKey.accessToken.rawValue:
            return GoogleUserInfoKey.accessToken
        case GoogleUserInfoKey.accessTokenExpirationDate.rawValue:
            return GoogleUserInfoKey.accessTokenExpirationDate
        case GoogleUserInfoKey.idToken.rawValue:
            return GoogleUserInfoKey.idToken
        case GoogleUserInfoKey.idTokenExpirationDate.rawValue:
            return GoogleUserInfoKey.idTokenExpirationDate
        case GoogleUserInfoKey.refreshToken.rawValue:
            return GoogleUserInfoKey.refreshToken
        default:
            return nil
        }
    }
    
    
    /// accessTokenExpirationDate を取得
    /// UserDefaultsにUnixtimeで保存
    /// 無い場合はnilを返す
    ///
    /// - Returns: Date or nil
    public func getAccessTokenExpirationDate() -> Date? {
        if let dateUnixStr =  self.userInfo[GoogleUserInfoKey.accessTokenExpirationDate] as String! {
            let dateUnix = TimeInterval(Int(dateUnixStr)!)
            return  Date.init(timeIntervalSince1970: dateUnix)
        } else {
            return nil
        }
    }

    /// GIDAuthentication.accessTokenExpirationDate から得た Date! を保存
    ///
    /// - Parameter d: Date!
    public func setAccessTokenExpirationDate(_ d: Date!) {
        self.userInfo[GoogleUserInfoKey.accessTokenExpirationDate] = String(d.timeIntervalSince1970)
    }
    
    /// idTokenExpirationDate を取得
    /// UserDefaultsにUnixtimeで保存
    /// 無い場合はnilを返す
    ///
    /// - Returns: Date or nil
    public func getIdTokenExpirationDate() -> Date? {
        if let dateUnixStr = self.userInfo[GoogleUserInfoKey.idTokenExpirationDate] as String! {
            let dateUnix = TimeInterval(Int(dateUnixStr)!)
            return  Date.init(timeIntervalSince1970: dateUnix)
        } else {
            return nil
        }
    }
    
    /// idTokenExpirationDate から得た Date! を保存
    ///
    /// - Parameter d: Date!
    public func setIdTokenExpirationDate(_ d: Date!) {
        self.userInfo[GoogleUserInfoKey.idTokenExpirationDate] = String(d.timeIntervalSince1970)
    }
    
    /// 呼び出された時点で self.userInfo に設定されている値だけをUserDefaultsにJSONとして保存する
    /// JSONにはNULLが存在しない
    public func save() {
        var userInfoForJson: Dictionary<String, String> = [:]
        self.userInfo.forEach { (key, value) in
            userInfoForJson[key.rawValue] = value
        }
        let json = JSON(userInfoForJson)
        let str: String = json.rawString([writtingOptionsKeys.castNilToNSNull : false])!
        ToshokanUserDefaultsModel.sharedUserInfo.saveGoogleUserInfo(userInfo: str)
    }
    
}
