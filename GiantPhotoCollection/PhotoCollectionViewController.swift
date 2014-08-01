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

    init(fetchResult: PHFetchResult, title: String) {
        self.fetchResult = fetchResult
        
        self.flowLayout = build(UICollectionViewFlowLayout()) {
            $0.itemSize = CGSize(width: 320, height: 160)
            $0.minimumInteritemSpacing = 0.0
            $0.minimumLineSpacing = 0.0
        }
        
        self.wallpaperManager = WallpaperManager(fetchResult: self.fetchResult,
            wallpaperImageSize: self.flowLayout.itemSize,
            thumbnailSize: CGSize(width: 20, height: 20))

        super.init(collectionViewLayout: self.flowLayout)
        self.title = title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        self.collectionView.registerClass(AssetsCell.classForCoder(), forCellWithReuseIdentifier: photoCellReuseIdentifier)
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
        }
    }
}
