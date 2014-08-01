//
//  AlbumTableViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photos"
        
        build(self.tableView) {
            $0.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.separatorColor = UIColor(white: 1.0, alpha: 0.1)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return build(tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell) {
            $0.textLabel.text = "All Photos"
            $0.textLabel.textColor = UIColor.whiteColor()
            $0.accessoryType = .DisclosureIndicator
            $0.backgroundColor = self.tableView.backgroundColor
        }
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        
        let viewController = PhotoCollectionViewController(fetchResult: fetchResult, title: "All Photos")
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
