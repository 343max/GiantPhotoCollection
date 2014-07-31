//
//  AppDelegate.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        let albumTableViewController = AlbumTableViewController(style: UITableViewStyle.Plain)
        let navigationController = UINavigationController(rootViewController: albumTableViewController)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()
        
        return true
    }

}

