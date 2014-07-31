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
    
    init(fetchResult: PHFetchResult, title: String) {
        self.fetchResult = fetchResult
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.title = title
    }

}
