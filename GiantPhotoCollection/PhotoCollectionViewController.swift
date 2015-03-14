//
//  PhotoCollectionViewController.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

protocol PhotoCollectionViewControllerDelegate {
    func didTapThumb(#photoCollectionViewController: PhotoCollectionViewController, thumbIndex: Int)
}

enum ThumbScrollPosition {
    case FromStart(Int)
    case FromEnd(Int)

    func absoluteIndex(#countOfItems: Int) -> Int {
        switch self {
            case .FromStart(let index):
                return index
            case .FromEnd(let indexFromEnd):
                return countOfItems - indexFromEnd - 1;
        }
    }
}

class PhotoCollectionViewController: UICollectionViewController {
    let fetchResult: PHFetchResult
    let flowLayout: UICollectionViewFlowLayout
    let photoCellReuseIdentifier = "PhotoCell"
    var photoSegmentManager: PhotoSegmentController!
    let thumbnailSize: CGSize
    var delegate: PhotoCollectionViewControllerDelegate?
    var initialScrollPosition: ThumbScrollPosition?
    
    required convenience init(coder aDecoder: NSCoder) {
        assert(false, "should not be called")
        self.init(fetchResult: PHFetchResult(), title: "", thumbnailSize: CGSize.zeroSize)
    }
    
    init(fetchResult: PHFetchResult, title: String, thumbnailSize: CGSize, initialScrollPosition: ThumbScrollPosition? = nil) {
        self.fetchResult = fetchResult
        self.thumbnailSize = thumbnailSize
        self.initialScrollPosition = initialScrollPosition

        self.flowLayout = build(UICollectionViewFlowLayout()) {
            $0.minimumInteritemSpacing = 0.0
            $0.minimumLineSpacing = 0.0
        }
        
        super.init(collectionViewLayout: self.flowLayout)
        self.title = title
    }
    
    func didTapThumb(thumbIndex: Int) {
        self.delegate?.didTapThumb(photoCollectionViewController: self, thumbIndex: thumbIndex)
    }
    
    func scrollTo(#thumbnailIndex: ThumbScrollPosition, animated: Bool) {
        let index = thumbnailIndex.absoluteIndex(countOfItems: self.photoSegmentManager.fetchResult.count)
        let (segmentIndex, _, _) = self.photoSegmentManager.position(index)
        self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: segmentIndex, inSection: 0),
                atScrollPosition: .CenteredVertically,
                animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let segmentSize = PhotoSegmentController.segmentSize(viewWidth: self.view.bounds.width, thumbnailSize: thumbnailSize)
        self.flowLayout.itemSize = segmentSize

        self.photoSegmentManager = PhotoSegmentController(fetchResult: self.fetchResult,
                                                          segmentSize: segmentSize,
                                                        thumbnailSize: thumbnailSize,
                                                                scale: self.view.contentScaleFactor)

        build(self.collectionView!) {
            $0.indicatorStyle = .White
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.registerClass(AssetsCell.classForCoder(), forCellWithReuseIdentifier: self.photoCellReuseIdentifier)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let scrollPosition = self.initialScrollPosition {
            self.scrollTo(thumbnailIndex: scrollPosition, animated: false)
            self.initialScrollPosition = nil
        }
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoSegmentManager.segmentCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return build(collectionView.dequeueReusableCellWithReuseIdentifier(photoCellReuseIdentifier, forIndexPath: indexPath) as! AssetsCell) {
            $0.photoSegmenetManager = self.photoSegmentManager
            $0.segmentIndex = indexPath.row
            $0.didTapAction = TargetActionWrapper(target: self, action: PhotoCollectionViewController.didTapThumb)
        }
    }
}
