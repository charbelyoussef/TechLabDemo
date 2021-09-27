//
//  AppDelegate.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        UserDefaults.standard.set(true, forKey: "AdsActivated")

        return true
    }
}
