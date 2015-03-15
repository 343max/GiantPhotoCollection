//
//  PhotoCell.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

class AssetsCell: UICollectionViewCell {
    let imageView: UIImageView
    var gestureRecognizer: UITapGestureRecognizer?
    weak var photoSegmenetManager: PhotoSegmentController?
    var segmentIndex: Int?
    var didTapAction: TargetAction?
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))
        
        super.init(frame: frame)
        
        self.addSubview(self.imageView)
        self.gestureRecognizer = build(UITapGestureRecognizer(target: self, action: "didTap:")) {
            self.addGestureRecognizer($0)
        }
    }
    
    override func prepareForReuse() {
        self.segmentIndex = nil
        self.imageView.image = nil
    }
    
    @objc func didTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if let index = self.photoSegmenetManager!.assetIndex(position: tapGestureRecognizer.locationInView(self), segmentIndex: self.segmentIndex!) {
            if let action = self.didTapAction {
                action.performAction(index)
            }
        }
    }
}
