//
//  AppDelegate.swift
//  firebase_ios
//
//  Created by Idelfonso Gutierrez Jr. on 5/16/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //look in the main bundle for the Google-info.plist
        FIRApp.configure()
        return true
    }

}

