//
//  PhotoCell.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 31/07/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView
    
    init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))

        super.init(frame: frame)
        self.addSubview(self.imageView)
    }
}
