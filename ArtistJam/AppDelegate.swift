//
//  AppDelegate.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coreDataStack = CoreDataStack()

    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.tintColor = UIColor.darkGray
        UITabBar.appearance().tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1)
        UITextField.appearance().tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:0.5)
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: poolID())
        AWSServiceManager
            .default().defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credentialProvider)
        
        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }


}

