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
    let imageContentMode = PHImageContentMode.AspectFill
    var imageSize = CGSize(width: 20, height: 20)
    var targetSize: CGSize {
    get {
        return CGSize(width: self.imageSize.width * 2.0, height: self.imageSize.height * 2.0)
    }
    }
    var imageManager: PHCachingImageManager?
    
    var assets: [PHAsset]? {
    willSet {
        if let assets = self.assets {
            self.stopLoadingAssets(assets)
        }
    }
    didSet {
        if let assets = self.assets {
            self.startLoadingAssets(assets)
            self.loadImages(assets)
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
        self.assets = nil
    }
    
    func stopLoadingAssets(assets: [PHAsset]) {
        self.imageManager!.stopCachingImagesForAssets(assets,
            targetSize: self.targetSize,
            contentMode: self.imageContentMode,
            options: nil)
    }
    
    func startLoadingAssets(assets: [PHAsset]) {
        self.imageManager!.startCachingImagesForAssets(assets,
            targetSize: self.targetSize,
            contentMode: self.imageContentMode,
            options: nil)
    }
    
    func createWallpaperImage(images: [Int: UIImage]) {
        let assetsPerRow = CGFloat(self.bounds.width / self.imageSize.width)
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 2.0)
        
        for i in images.keys {
            let column: CGFloat = CGFloat(CGFloat(i) % assetsPerRow)
            let row: CGFloat = CGFloat(CGFloat(CGFloat(i) - CGFloat(column)) / CGFloat(assetsPerRow))
            let frame = CGRect(origin: CGPoint(x: column * self.imageSize.width, y: row * self.imageSize.height), size: self.imageSize)
            println("imageSize: \(images[i]!.size)")
            images[i]!.drawInRect(frame)
        }
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func loadImages(assets: [PHAsset]) {
        var images: [Int: UIImage] = [:]
        var imagesLoaded = 0
        
        for i in 0 ..< assets.count {
            self.imageManager!.requestImageForAsset(assets[i],
                targetSize: self.targetSize,
                contentMode: self.imageContentMode,
                options: nil, resultHandler: { (image, info) in
                    images[i] = image
                    imagesLoaded++
                    if (imagesLoaded == assets.count) {
                        self.createWallpaperImage(images)
                    }
                })
        }
    }
}
