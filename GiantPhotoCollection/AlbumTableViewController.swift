//
//  AlbumTableViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit

class AlbumTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = "All Photos"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
}
