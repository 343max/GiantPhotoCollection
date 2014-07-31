//
//  PhotoCollectionViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

func build<T>(object: T, block: (object: T) -> ()) -> T {
    block(object: object)
    return object
}

class PhotoCollectionViewController: UICollectionViewController {
    let fetchResult: PHFetchResult
    let imageManager: PHCachingImageManager
    let flowLayout: UICollectionViewFlowLayout
    let photoCellReuseIdentifier = "PhotoCell"
    
    init(fetchResult: PHFetchResult, title: String) {
        self.fetchResult = fetchResult
        
        self.flowLayout = build(UICollectionViewFlowLayout()) {
            $0.itemSize = CGSize(width: 80, height: 80)
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
    
    func updateCachedAssets() {
        let indexPaths = self.collectionView.indexPathsForVisibleItems() as [NSIndexPath]
        let assets = indexPaths.map { (let indexPath) -> PHAsset in
            return self.fetchResult[indexPath.row] as PHAsset
        }
        self.imageManager.startCachingImagesForAssets(assets,
            targetSize: self.flowLayout.itemSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerClass(PhotoCell.classForCoder(), forCellWithReuseIdentifier: photoCellReuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCachedAssets()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellReuseIdentifier, forIndexPath: indexPath) as PhotoCell
        cell.indexPath = indexPath

        self.imageManager.requestImageForAsset(self.fetchResult[indexPath.row] as PHAsset,
            targetSize: self.flowLayout.itemSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { (image: UIImage!, info: [NSObject : AnyObject]!) in
                if (indexPath == cell.indexPath) {
                    println("indexPath: \(indexPath) image:\(image)")
                    cell.imageView.image = image
                }
            })
        
        return cell
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView!)  {
        self.updateCachedAssets()
    }
    
}
