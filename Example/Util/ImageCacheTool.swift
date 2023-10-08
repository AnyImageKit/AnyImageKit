import Kingfisher
import AnyImageKit
import UIKit

struct ImageCacheTool {
    let cache: ImageCache
    
    init() {
        cache = ImageCache.default
    }
}

extension ImageCacheTool: ImageCacheable {
    
    /// 删除所有缓存
    public func clearAll() {
        cache.clearCache()
    }
    
    /// 写入缓存
    /// - Parameters:
    ///   - image: 图片
    ///   - key: 标识符
    public func store(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key)
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - key: 标识符
    public func retrieveImage(forKey key: String) -> UIImage? {
        cache.retrieveImageInMemoryCache(forKey: key)
    }
}
