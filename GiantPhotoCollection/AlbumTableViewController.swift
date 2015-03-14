//
//  AlbumTableViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewController: UITableViewController, PhotoCollectionViewControllerDelegate {
    let sizes = [CGSize(width: 25, height: 25), CGSize(width: 37.5, height: 37.5), CGSize(width: 75, height: 75)]
//    let sizes = [CGSize(width: 20, height: 20), CGSize(width: 40, height: 40), CGSize(width: 80, height: 80)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photos"
        
        build(self.tableView) {
            $0.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.separatorColor = UIColor(white: 1.0, alpha: 0.1)
            $0.indicatorStyle = .White
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return build(tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell) {
            $0.textLabel!.text = "All Photos"
            $0.textLabel!.textColor = UIColor.whiteColor()
            $0.accessoryType = .DisclosureIndicator
            $0.backgroundColor = self.tableView.backgroundColor
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
        
        let viewController = self.photoCollectionViewController(fetchResult, title: "All Photos", thumbnailSize: self.sizes.first!)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func photoCollectionViewController(fetchResult: PHFetchResult, title: String, thumbnailSize: CGSize) -> PhotoCollectionViewController {
        let viewController = PhotoCollectionViewController(fetchResult: fetchResult,
            title: "All Photos",
            thumbnailSize: thumbnailSize)
        viewController.delegate = self
        return viewController
    }
    
    
    
// MARK: PhotoCollectionViewControllerDelegate
    
    func didTapThumb(#photoCollectionViewController: PhotoCollectionViewController, thumbIndex: Int) {
        if (photoCollectionViewController.thumbnailSize == self.sizes.last!) {
            println("thumb: \(thumbIndex)")
        } else {
            func contains<T: Equatable>(array: [T], needle: T) -> Int? {
                for i in array.startIndex...array.endIndex {
                    if (array[i] == needle) {
                        return i
                    }
                }
                
                return nil
            }
            
            let oldVC = photoCollectionViewController
            let index = contains(self.sizes, oldVC.thumbnailSize)!
            let viewController = self.photoCollectionViewController(oldVC.fetchResult, title: oldVC.title!, thumbnailSize: self.sizes[index + 1])
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
    
}
