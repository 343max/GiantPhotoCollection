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
    var wallpaperManager: WallpaperManager?
    var wallpaperIndex: Int? {
    didSet {
        if let wallpaperIndex = self.wallpaperIndex {
            self.wallpaperManager!.createImageForWallpaper(wallpaperIndex: wallpaperIndex,
                callback: { (image, index) in
                    if (index != self.wallpaperIndex) {
                        return
                    }
                    
                    self.imageView.image = image
                })
        }
    }
    }
    
    init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))

        super.init(frame: frame)
        self.addSubview(self.imageView)
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
}
