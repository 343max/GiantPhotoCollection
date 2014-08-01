//
//  WallpaperManager.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 01/08/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

import UIKit
import Photos

class WallpaperManager {
    typealias CreatedWallpaperImageCallback = (image: UIImage, index: Int) -> ()
    
    let wallpaperImageSize: CGSize
    let thumbnailSize: CGSize
    let imageManager: PHImageManager
    let queue: dispatch_queue_t
    let fetchResult: PHFetchResult
    let cache: NSCache
    
    let thumbsPerRow: Int
    let thumbsPerWallpaper: Int
    let wallpaperCount: Int
    
    init(fetchResult: PHFetchResult, wallpaperImageSize: CGSize, thumbnailSize: CGSize) {
        self.fetchResult = fetchResult
        self.wallpaperImageSize = wallpaperImageSize
        self.thumbnailSize = thumbnailSize
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        self.imageManager = PHImageManager()
        self.cache = NSCache()
        
        self.thumbsPerRow = Int(floor(wallpaperImageSize.width / thumbnailSize.width))
        self.thumbsPerWallpaper = Int(floor(wallpaperImageSize.height / thumbnailSize.height)) * self.thumbsPerRow
        
        self.wallpaperCount = Int(ceil(Double(self.fetchResult.count) / Double(self.thumbsPerWallpaper)))
    }
    
    func createImageForWallpaper(#wallpaperIndex: Int, callback: CreatedWallpaperImageCallback) {
        if let image: UIImage = self.cache.objectForKey(wallpaperIndex) as? UIImage {
            callback(image: image, index: wallpaperIndex)
            return
        }

        dispatch_async(self.queue) {
            let assets = self.assets(range: self.rangeForAssets(wallpaperIndex: wallpaperIndex))
            self.loadImages(assets, wallpaperIndex: wallpaperIndex, callback: callback)
        }
    }
    
    private func rangeForAssets(#wallpaperIndex: Int) -> Range<Int> {
        let start = wallpaperIndex * self.thumbsPerWallpaper
        let end = min((wallpaperIndex + 1) * self.thumbsPerWallpaper, self.fetchResult.count)
        return start..<end
    }
    
    private func assets(#range: Range<Int>) -> [PHAsset] {
        var assets = [PHAsset]()
        for i in range {
            assets += self.fetchResult[i] as PHAsset
        }
        return assets
    }
    
    private func loadImages(assets: [PHAsset], wallpaperIndex: Int, callback: CreatedWallpaperImageCallback) {
        var images = [Int: UIImage]()
        
        for i in 0..<assets.count {
            self.imageManager.requestImageForAsset(assets[i],
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.AspectFill,
                options: build(PHImageRequestOptions()) {
                    $0.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
                },
                resultHandler: { (image, info) in
                    println(i)
                    images[i] = image
                    if (images.count == assets.count) {
                        dispatch_async(self.queue) {
                            self.drawWallpaper(images, wallpaperIndex: wallpaperIndex, callback: callback)
                        }
                    }
                })
        }
    }
    
    private func drawWallpaper(images: [Int: UIImage], wallpaperIndex: Int, callback: CreatedWallpaperImageCallback) {
        
        UIGraphicsBeginImageContextWithOptions(self.wallpaperImageSize, false, 2.0)
        
        for i in images.keys {
            let column: CGFloat = CGFloat(i % self.thumbsPerRow)
            let row: CGFloat = CGFloat(CGFloat(CGFloat(i) - CGFloat(column)) / CGFloat(self.thumbsPerRow))
            let frame = CGRect(origin: CGPoint(x: column * self.thumbnailSize.width, y: row * self.thumbnailSize.height), size: self.thumbnailSize)
            images[i]!.drawInRect(frame)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.cache.setObject(image, forKey: wallpaperIndex)
            callback(image: image, index: wallpaperIndex)
        }
    }
}
