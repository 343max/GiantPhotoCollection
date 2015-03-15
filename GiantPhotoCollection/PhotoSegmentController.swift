
import UIKit
import Photos

class PhotoSegmentController {
    typealias CreatedSegmentImageCallback = (image: UIImage, index: Int) -> ()

    class JobToken {
        typealias CreatedSegmentImageCallback = PhotoSegmentController.CreatedSegmentImageCallback

        var shouldCancel: Bool = false
        var callbacks: [CreatedSegmentImageCallback] = []

        func addCallback(callback: CreatedSegmentImageCallback) {
            self.callbacks += [callback]
        }

        func executeCallbacks(#image: UIImage, index: Int) {
            for callback in self.callbacks {
                callback(image: image, index: index)
            }
        }
    }
    
    let fetchResult: PHFetchResult
    let segmentSize: CGSize
    let thumbnailSize: CGSize
    let scale: CGFloat
    let imageManager: PHImageManager
    let queue: dispatch_queue_t
    let cache: NSCache
    
    let thumbsPerRow: Int
    let thumbsPerSegment: Int
    let segmentCount: Int

    var jobs: [Int: JobToken] = [:]

    class func segmentSize(#viewWidth: CGFloat, thumbnailSize: CGSize) -> CGSize {
        let rowCount = floor(150.0 / thumbnailSize.height)
        return CGSize(width: viewWidth, height: rowCount * thumbnailSize.height)
    }

    init(fetchResult: PHFetchResult, segmentSize: CGSize, thumbnailSize: CGSize, scale: CGFloat) {
        self.fetchResult = fetchResult
        self.segmentSize = segmentSize
        self.thumbnailSize = thumbnailSize
        self.scale = scale
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        self.imageManager = PHImageManager.defaultManager()
        self.cache = NSCache()
        
        self.thumbsPerRow = Int(ceil(segmentSize.width / thumbnailSize.width))
        self.thumbsPerSegment = Int(floor(segmentSize.height / thumbnailSize.height)) * self.thumbsPerRow
        
        self.segmentCount = Int(ceil(Double(self.fetchResult.count) / Double(self.thumbsPerSegment)))
    }

    func createSegmentImage(#segmentIndex: Int, callback: CreatedSegmentImageCallback?) {
        if let image: UIImage = self.cache.objectForKey(segmentIndex) as? UIImage {
            if let callback = callback {
                callback(image: image, index: segmentIndex)
            }
            return
        }

        let jobToken: JobToken
        if let token = self.jobs[segmentIndex] {
            jobToken = token
        } else {
            jobToken = JobToken()
            self.jobs[segmentIndex] = jobToken
        }

        if let callback = callback {
            jobToken.addCallback(callback)
        }

        dispatch_async(self.queue) {
            if let assets = self.assets(range: self.rangeForAssets(segmentIndex: segmentIndex), job: jobToken) {
                if let images = self.loadImages(assets, job: jobToken) {
                    if let segmentImage = self.drawSegment(images, job: jobToken) {
                        self.cache.setObject(segmentImage, forKey: segmentIndex)
                        dispatch_async(dispatch_get_main_queue()) {
                            jobToken.executeCallbacks(image: segmentImage, index: segmentIndex)
                        }
                    }
                }
            }
            self.jobs[segmentIndex] = nil
        }
    }

    func cancelSegmentImage(#segmentIndex: Int) {
        if self.jobs[segmentIndex] != nil {
            println("cancel segment \(segmentIndex)")
        }
        self.jobs[segmentIndex]?.shouldCancel = true
        self.jobs[segmentIndex] = nil
    }
    
    func position(var thumbIndex: Int) -> (segmentIndex: Int, row: Int, column: Int) {
        let column = thumbIndex % self.thumbsPerRow
        thumbIndex -= column
        let row = (thumbIndex % self.thumbsPerSegment) / self.thumbsPerRow
        thumbIndex -= row * self.thumbsPerRow
        let segmentIndex = thumbIndex / self.thumbsPerSegment
        
        return (segmentIndex, row, column)
    }
    
    func assetIndex(#position: CGPoint) -> Int? {
        let column: Int = Int(floor(position.x / self.thumbnailSize.width))
        let row: Int = Int(floor(position.y / self.thumbnailSize.height))
        let index = self.thumbsPerRow * row + column
        
        if (row < 0 || column < 0 || column > self.thumbsPerRow || index > self.thumbsPerSegment) {
            return nil
        } else {
            return self.thumbsPerRow * row + column
        }
    }
    
    func assetIndex(#position: CGPoint, segmentIndex: Int) -> Int? {
        if let assetIndex = self.assetIndex(position: position) {
            let index = assetIndex + self.thumbsPerSegment * segmentIndex
            if (index < self.fetchResult.count) {
                return index
            }
        }
        
        return nil
    }
    
    private func rangeForAssets(#segmentIndex: Int) -> Range<Int> {
        let start = segmentIndex * self.thumbsPerSegment
        let end = min((segmentIndex + 1) * self.thumbsPerSegment, self.fetchResult.count)
        return start..<end
    }
    
    private func assets(#range: Range<Int>, job: JobToken) -> [PHAsset]? {
        var assets = [PHAsset]()
        for i in range {
            if (job.shouldCancel) {
                return nil
            }

            assets += [self.fetchResult[i] as! PHAsset]
        }
        return assets
    }
    
    private func loadImages(assets: [PHAsset], job: JobToken) -> [Int:UIImage]? {
        var images = [Int: UIImage]()
        
        for i in 0..<assets.count {
            if (job.shouldCancel) {
                return nil
            }

            self.imageManager.requestImageForAsset(assets[i],
                targetSize: self.thumbnailSize,
                contentMode: PHImageContentMode.AspectFill,
                options: build(PHImageRequestOptions()) {
                    $0.deliveryMode = PHImageRequestOptionsDeliveryMode.FastFormat
                    $0.synchronous = true
                },
                resultHandler: { (image, info) in
                    images[i] = image
                })
        }
        
        return images;
    }
    
    private func drawSegment(images: [Int: UIImage], job: JobToken) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(self.segmentSize, false, 2.0)
        
        for i in images.keys {
            if (job.shouldCancel) {
                return nil
            }

            let column: CGFloat = CGFloat(i % self.thumbsPerRow)
            let row: CGFloat = CGFloat(CGFloat(CGFloat(i) - CGFloat(column)) / CGFloat(self.thumbsPerRow))
            let frame = CGRect(origin: CGPoint(x: column * self.thumbnailSize.width, y: row * self.thumbnailSize.height), size: self.thumbnailSize)
            images[i]!.drawInRect(frame)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
