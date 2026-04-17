//
//  Cache.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/21/25.
//

import Foundation
import SDWebImageSwiftUI
import UIKit

final class BoardGameCache {
    static let shared = BoardGameCache()
    
    // NSCache requires reference types for keys, so we use NSString.
    
    private var cache = [Int: BoardGameModel]()
    private var feedKeys = [Int]()
    
    private init() {}
    
    func getFeedKeys() -> [Int] {
        return feedKeys
    }
    
    func get(id: Int) -> BoardGameModel? {
        return cache[id]
    }
    
    func set(_ boardGame: BoardGameModel) {
        cache[boardGame.id] = boardGame
    }
}



final class ImageCache {
    private let cache = SDImageCache()
    static let shared = ImageCache()

    private init() {}

    func getImage(for id : Int) -> UIImage? {
        return cache.imageFromCache(forKey: "\(id)")
    }

    func storeImage(_ image: UIImage, for id: Int) {
        cache.store(image, forKey: "\(id)")
    }

    func removeImage(for id: Int) {
        cache.removeImage(forKey: "\(id)")
    }

    func clearCache() {
        cache.clearMemory()
    }
}

enum ImageCacheContext: String {
    case profiles
    case gameNights
    case `default`

    var cache: SDImageCache {
        switch self {
        case .profiles: return AppImageCaches.profiles
        case .gameNights: return AppImageCaches.gameNights
        case .default: return SDImageCache.shared
        }
    }
}

enum AppImageCaches {
    static let profiles: SDImageCache = {
        let cache = SDImageCache(namespace: "profiles")
        cache.config.maxDiskAge = 60 * 60 * 24 * 14 // 14 days
        cache.config.maxDiskSize = 50 * 1024 * 1024 // 50 MB
        return cache
    }()

    static let gameNights: SDImageCache = {
        let cache = SDImageCache(namespace: "gameNights")
        cache.config.maxDiskAge = 60 * 60 * 24 * 3 // 3 days
        cache.config.maxDiskSize = 150 * 1024 * 1024 // 150 MB
        return cache
    }()

    static func registerAll() {
        SDImageCachesManager.shared.addCache(profiles)
        SDImageCachesManager.shared.addCache(gameNights)
    }
}


