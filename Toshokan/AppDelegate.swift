//
//  AppDelegate.swift
//  Toshokan
//
//  Created by jote on 2017/02/28.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
//        初回起動
        let userDefaults = UserDefaults()
        if !userDefaults.bool(forKey: ToshokanUserDefaultsKey.hasAgreement.rawValue) {
            //初回画面を起動、契約に同意させる
            let s = UIStoryboard(name: "Agreement", bundle: nil)
            let vc = s.instantiateInitialViewController()
            self.window?.rootViewController = vc
        }
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        if (error == nil) {
            // サインイン成功
            // Perform any operations on signed in user here.
            GoogleUserModel.share.userId = user.userID
            GoogleUserModel.share.name = user.profile.name
            GoogleUserModel.share.accessToken = user.authentication.accessToken
            GoogleUserModel.share.setAccessTokenExpirationDate(user.authentication.accessTokenExpirationDate)
            GoogleUserModel.share.refreshToken = user.authentication.refreshToken
            GoogleUserModel.share.idToken = user.authentication.idToken
            GoogleUserModel.share.setIdTokenExpirationDate(user.authentication.idTokenExpirationDate)
            
            print("userId: \(GoogleUserModel.share.userId), accessToken: \(GoogleUserModel.share.accessToken)")
            GoogleUserModel.share.save()
        } else {
            // サインイン失敗
            print("サインイン失敗したよ！！！！！   \(error.localizedDescription)")
        }
    }


}
