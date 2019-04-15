//
//  AppDelegate.swift
//  ios
//
//  Copyright © 2018 Tinode. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let kTinodeHasRunBefore = "tinodeHasRunBefore"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: AppDelegate.kTinodeHasRunBefore) {
            // Clear the app keychain.
            KeychainWrapper.standard.removeAllKeys()
            userDefaults.set(true, forKey: AppDelegate.kTinodeHasRunBefore)
        } else {
            if let token = KeychainWrapper.standard.string(
                forKey: LoginViewController.kTokenKey), !token.isEmpty {
                let tinode = Cache.getTinode()
                do {
                    let (hostName, useTLS, _) = SettingsHelper.getConnectionSettings()
                    // TODO: implement TLS.
                    tinode.setAutoLoginWithToken(token: token)
                    _ = try tinode.connect(to: (hostName ?? Cache.kHostName), useTLS: (useTLS ?? false))?.getResult()
                    let msg = try tinode.loginToken(token: token, creds: nil).getResult()
                    if let code = msg.ctrl?.code, code < 300 {
                        print("login successful for: \(tinode.myUid!)")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController =
                            storyboard.instantiateViewController(
                                withIdentifier: "ChatsNavigator") as! UINavigationController
                        self.window!.rootViewController = initialViewController
                    }
                } catch {
                    print("Failed to automatically login to Tinode: \(error).")
                }
            }
        }
        return true
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


}
