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
        let navigationController = build(UINavigationController(rootViewController: albumTableViewController)) {
            $0.navigationBar.barStyle = UIBarStyle.Black
        }
        
        self.window = build(UIWindow(frame: UIScreen.mainScreen().bounds)) {
            $0.rootViewController = navigationController
            $0.makeKeyAndVisible()
        }
        
        return true
    }

}

