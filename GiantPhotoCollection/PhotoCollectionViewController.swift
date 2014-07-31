//
//  PhotoCollectionViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

func with<T>(object: T, block: (object: T) -> ()) -> T {
    block(object: object)
    return object
}

class PhotoCollectionViewController: UICollectionViewController {
    let fetchResult: PHFetchResult
    let flowLayout: UICollectionViewFlowLayout
    let photoCellReuseIdentifier = "PhotoCell"
    
    init(fetchResult: PHFetchResult, title: String) {
        self.fetchResult = fetchResult
        
        self.flowLayout = with(UICollectionViewFlowLayout()) {
            $0.itemSize = CGSize(width: 40, height: 40)
            $0.minimumInteritemSpacing = 0.0
            $0.minimumLineSpacing = 0.0
        }

        super.init(collectionViewLayout: self.flowLayout)
        self.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.grayColor()
        self.collectionView.registerClass(PhotoCell.classForCoder(), forCellWithReuseIdentifier: photoCellReuseIdentifier)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellReuseIdentifier, forIndexPath: indexPath) as PhotoCell
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
    
}
