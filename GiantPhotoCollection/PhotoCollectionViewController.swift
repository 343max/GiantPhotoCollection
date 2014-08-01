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
    let imageManager: PHCachingImageManager
    let flowLayout: UICollectionViewFlowLayout
    let photoCellReuseIdentifier = "PhotoCell"
    let assetsPerCell: Int = 128

    init(fetchResult: PHFetchResult, title: String) {
        self.fetchResult = fetchResult
        
        self.flowLayout = build(UICollectionViewFlowLayout()) {
            $0.itemSize = CGSize(width: 320, height: 160)
            $0.minimumInteritemSpacing = 0.0
            $0.minimumLineSpacing = 0.0
        }
        
        self.imageManager = PHCachingImageManager()

        super.init(collectionViewLayout: self.flowLayout)
        self.title = title
    }
    
    deinit {
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    func assetsForIndexPath(indexPath: NSIndexPath) -> [PHAsset] {
        let loc = indexPath.row * self.assetsPerCell
        let end = loc + self.assetsPerCell
        var assets: [PHAsset] = []
        for i in loc...end {
            assets += self.fetchResult[i] as PHAsset
        }
        return assets
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
        // TODO: don't cut off any images
        return Int(floor(Double(fetchResult.count) / Double(self.assetsPerCell)))
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        return build(collectionView.dequeueReusableCellWithReuseIdentifier(photoCellReuseIdentifier, forIndexPath: indexPath) as AssetsCell) {
            $0.imageManager = self.imageManager
            $0.assets = self.assetsForIndexPath(indexPath)
        }
    }
}
