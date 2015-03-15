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
    let thumbsPerRow = [16, 8, 4]
    let scale: CGFloat

    override init(style: UITableViewStyle) {
        self.scale = UIScreen.mainScreen().scale
        super.init(style: style)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        let thumbSize = self.thumbSize(thumbsPerRow: self.thumbsPerRow.first!)
        let viewController = self.photoCollectionViewController(fetchResult, title: "All Photos", thumbnailSize: thumbSize, initialScrollPosition: .FromEnd(0))
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func thumbSize(#thumbsPerRow: Int) -> CGSize {
        let viewWidth = self.view.bounds.width
        let scale = self.scale
        let sideLength = ceil(viewWidth / CGFloat(thumbsPerRow) * scale) / scale;
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func photoCollectionViewController(fetchResult: PHFetchResult,
        title: String, thumbnailSize: CGSize, initialScrollPosition: ThumbScrollPosition? = nil) -> PhotoCollectionViewController
    {
        let viewController = PhotoCollectionViewController(fetchResult: fetchResult,
            title: "All Photos",
            thumbnailSize: thumbnailSize,
            initialScrollPosition: initialScrollPosition
        )
        viewController.delegate = self
        return viewController
    }

    
// MARK: PhotoCollectionViewControllerDelegate
    
    func didTapThumb(#photoCollectionViewController: PhotoCollectionViewController, thumbIndex: Int) {
        func indexOf(size: CGSize, thumbsPerRow: [Int]) -> Int? {
            for i in thumbsPerRow.startIndex...thumbsPerRow.endIndex {
                if (self.thumbSize(thumbsPerRow: thumbsPerRow[i]) == size) {
                    return i
                }
            }
            return nil
        }

        let index = indexOf(photoCollectionViewController.thumbnailSize, self.thumbsPerRow) as Int!

        if (index == self.thumbsPerRow.endIndex - 1) {
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

            self.thumbsPerRow
            
            let viewController = self.photoCollectionViewController(photoCollectionViewController.fetchResult,
                                                             title: photoCollectionViewController.title!,
                                                     thumbnailSize: self.thumbSize(thumbsPerRow:self.thumbsPerRow[index + 1]),
                                             initialScrollPosition: .FromStart(thumbIndex))
            self.navigationController!.pushViewController(viewController, animated: true)
        }
    }
    
}
