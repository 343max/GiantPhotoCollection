
import UIKit
import Photos

protocol PhotoSemgentControllerDelegate: NSObjectProtocol {
    func photoSegmentController(photoSegmentController: PhotoSegmentController, didCreateImage: UIImage, forSegment: Int)
}

class PhotoSegmentController {
    weak var delegate: PhotoSemgentControllerDelegate?
    
    let fetchResult: PHFetchResult
    let segmentSize: CGSize
    let thumbnailSize: CGSize
    let scale: CGFloat
    let imageManager: PHImageManager
    let cache: NSCache
    let queue: NSOperationQueue
    let operations: NSMapTable

    let thumbsPerRow: Int
    let thumbsPerSegment: Int
    let segmentCount: Int

    class func segmentSize(#viewWidth: CGFloat, thumbnailSize: CGSize) -> CGSize {
        let rowCount = min(floor(200.0 / thumbnailSize.height), 4)
        return CGSize(width: viewWidth, height: rowCount * thumbnailSize.height)
    }

    init(fetchResult: PHFetchResult, segmentSize: CGSize, thumbnailSize: CGSize, scale: CGFloat) {
        self.fetchResult = fetchResult
        self.segmentSize = segmentSize
        self.thumbnailSize = thumbnailSize
        self.scale = scale
        self.queue = NSOperationQueue()
        self.queue.qualityOfService = NSQualityOfService.UserInitiated
        self.queue.maxConcurrentOperationCount = 1
        self.imageManager = PHImageManager.defaultManager()
        self.cache = NSCache()
        self.operations = NSMapTable.strongToWeakObjectsMapTable()
        
        self.thumbsPerRow = Int(ceil(segmentSize.width / thumbnailSize.width))
        self.thumbsPerSegment = Int(floor(segmentSize.height / thumbnailSize.height)) * self.thumbsPerRow
        
        self.segmentCount = Int(ceil(Double(self.fetchResult.count) / Double(self.thumbsPerSegment)))
    }

    class CreateSegmentOperation: NSOperation {
        let segmentIndex: Int
        var image: UIImage?
        weak var controller: PhotoSegmentController?

        init(segmentIndex: Int) {
            self.segmentIndex = segmentIndex
            super.init()
        }

        override func main() {
            let controller = self.controller!
            if let assets = controller.assets(range: controller.rangeForAssets(segmentIndex: self.segmentIndex), operation: self) {
                if let images = controller.loadImages(assets, operation: self) {
                    if let clippedImages = controller.clipImages(images, operation: self) {
                        if let segmentImage = controller.drawSegment(clippedImages, operation: self) {
                            self.image = segmentImage
                        }
                    }
                }
            }
        }
    }

    func createSegmentImage(#segmentIndex: Int) -> UIImage? {
        if segmentIndex < 0 || segmentIndex >= self.segmentCount {
            return nil
        }

        if let image: UIImage = self.cache.objectForKey(segmentIndex) as? UIImage {
            return image
        }

        if let operation: NSOperation = self.operations.objectForKey(segmentIndex) as? NSOperation {
            if (!operation.cancelled) {
                return nil
            }
        }

        let operation = CreateSegmentOperation(segmentIndex: segmentIndex)
        operation.controller = self
        operation.completionBlock = {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let image = operation.image {
                    self.cache.setObject(image, forKey: operation.segmentIndex)
                    self.delegate?.photoSegmentController(self, didCreateImage: image, forSegment: operation.segmentIndex)
                }
            }
        }

        self.operations.setObject(operation, forKey: segmentIndex)
        self.queue.addOperation(operation)

        return nil
    }

    func cancelSegmentImage(#segmentIndex: Int) {
        if let operation: NSOperation = self.operations.objectForKey(segmentIndex) as? NSOperation {
            operation.cancel()
        }
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
    
    private func assets(#range: Range<Int>, operation: NSOperation) -> [PHAsset]? {
        var assets = [PHAsset]()
        for i in range {
            if (operation.cancelled) {
                return nil
            }

            assets += [self.fetchResult[i] as! PHAsset]
        }
        return assets
    }
    
    private func loadImages(assets: [PHAsset], operation: NSOperation) -> [Int:UIImage]? {
        var images = [Int: UIImage]()
        
        for i in 0..<assets.count {
            if (operation.cancelled) {
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

    private func clipImages(images: [Int: UIImage], operation: NSOperation) -> [Int: UIImage]? {
        var clippedImages: [Int: UIImage] = [:]

        for i in images.keys {
            if (operation.cancelled) {
                return nil
            }

            UIGraphicsBeginImageContextWithOptions(self.thumbnailSize, true, self.scale)
            let image = images[i]!
            let scale = max(self.thumbnailSize.width / image.size.width, self.thumbnailSize.height / image.size.height)
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let frame = CGRect(x: (self.thumbnailSize.width - size.width) / 2.0,
                y: (self.thumbnailSize.height - size.height) / 2.0,
                width: size.width,
                height: size.height)
            image.drawInRect(frame)

            clippedImages[i] = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return clippedImages
    }
    
    private func drawSegment(images: [Int: UIImage], operation: NSOperation) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(self.segmentSize, false, self.scale)

        for i in images.keys {
            if (operation.cancelled) {
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
