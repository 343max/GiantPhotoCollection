//
//  PhotoCollectionViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewController: UICollectionViewController {
    let fetchResult: PHFetchResult
    let flowLayout: UICollectionViewFlowLayout
    let photoCellReuseIdentifier = "PhotoCell"
    let wallpaperManager: WallpaperManager
    let remainingThumbnailSizes: [CGSize]

    init(fetchResult: PHFetchResult, title: String, thumbnailSizes:[CGSize]) {
        self.fetchResult = fetchResult
        
        let thumbnailSize = thumbnailSizes[0]
        self.remainingThumbnailSizes = Array(thumbnailSizes[1..<thumbnailSizes.count])
        
        self.flowLayout = build(UICollectionViewFlowLayout()) {
            $0.itemSize = CGSize(width: 320, height: 80)
            $0.minimumInteritemSpacing = 0.0
            $0.minimumLineSpacing = 0.0
        }
        
        self.wallpaperManager = WallpaperManager(fetchResult: self.fetchResult,
            wallpaperImageSize: self.flowLayout.itemSize,
            thumbnailSize: thumbnailSize)

        super.init(collectionViewLayout: self.flowLayout)
        self.title = title
    }
    
    func didTapThumb(thumbIndex: Int) {
        if (self.remainingThumbnailSizes.count > 0) {
            let nextViewController = PhotoCollectionViewController(fetchResult: self.fetchResult,
                title: self.title,
                thumbnailSizes: self.remainingThumbnailSizes)
            self.navigationController.pushViewController(nextViewController, animated: true)
            dispatch_async(dispatch_get_main_queue()) {
                nextViewController.scrollTo(thumbnailIndex: thumbIndex, animated: false)
            }
        } else {
            println("tapped thumbIndex: \(thumbIndex)")
        }
    }
    
    func scrollTo(#thumbnailIndex:Int, animated: Bool) {
        let (wallpaperIndex, _, _) = self.wallpaperManager.position(thumbnailIndex)
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: wallpaperIndex, inSection: 0),
            atScrollPosition: .CenteredVertically,
            animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build(self.collectionView) {
            $0.indicatorStyle = .White
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.registerClass(AssetsCell.classForCoder(), forCellWithReuseIdentifier: self.photoCellReuseIdentifier)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.wallpaperManager.wallpaperCount
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        return build(collectionView.dequeueReusableCellWithReuseIdentifier(photoCellReuseIdentifier, forIndexPath: indexPath) as AssetsCell) {
            $0.wallpaperManager = self.wallpaperManager
            $0.wallpaperIndex = indexPath.row
            $0.didTapAction = TargetActionWrapper(target: self, action: PhotoCollectionViewController.didTapThumb)
        }
    }
}
