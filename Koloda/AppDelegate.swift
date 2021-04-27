//
//  AppDelegate.swift
//  Koloda
//
//  Created by Eugene Andreyev on 07/01/2015.
//  Copyright (c) 07/01/2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
//		GADMobileAds.configure(withApplicationID: "ca-app-pub-8165662050219478~6938445749")
		
		return true
	}
}
