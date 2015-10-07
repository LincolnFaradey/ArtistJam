//
//  AppDelegate.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

//static NSString *ACCOUNT_ID = @"0175-1086-4679";
//static NSString *POOL_ID = @"eu-west-1:da1d6cdf-4cf6-480c-ad14-8cdec1357a20";
//static NSString *UNAUTH_ROLE = @"arn:aws:iam::017510864679:role/Cognito_ajcognitoUnauth_Role";
//
//static NSString *BUCKET = @"ajs3";

let POOL_ID = "eu-west-1:da1d6cdf-4cf6-480c-ad14-8cdec1357a20"
let BUCKET = "ajs3"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.tintColor = UIColor.darkGrayColor()
        UITabBar.appearance().tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1)
        UITextField.appearance().tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:0.5)
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: POOL_ID)
        
        AWSServiceManager
            .defaultServiceManager().defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest1, credentialsProvider: credentialProvider)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

