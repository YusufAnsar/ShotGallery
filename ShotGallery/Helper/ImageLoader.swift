//
//  ImageLoader.swift
//  ShotGallery
//
//  Created by Yusuf Ansar on 01/12/24.
//

import UIKit
import Photos

/// Utility class for loading images from PHAsset.
final class ImageLoader {

    // MARK: - Properties

    private static let cachingManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        return manager
    }()

    // MARK: - Public Methods

    /// Loads a thumbnail image for a given asset.
    /// - Parameters:
    ///   - asset: The `PHAsset` representing the image.
    ///   - targetSize: The desired size of the thumbnail.
    ///   - completion: A closure called with the loaded thumbnail or `nil` if it fails.
    static func loadThumbnail(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = createImageRequestOptions(deliveryMode: .fastFormat)
        cachingManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            completion(image)
        }
    }

    /// Loads the full-resolution image for a given asset.
    /// - Parameters:
    ///   - asset: The `PHAsset` representing the image.
    ///   - completion: A closure called with the full-resolution image or `nil` if it fails.
    static func loadFullImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = createImageRequestOptions(deliveryMode: .highQualityFormat)
        cachingManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            completion(data.flatMap { UIImage(data: $0) })
        }
    }

    // MARK: - Private Methods

    /// Creates a configured `PHImageRequestOptions` instance.
    /// - Parameter deliveryMode: The desired `PHImageRequestOptionsDeliveryMode`.
    /// - Returns: A configured `PHImageRequestOptions` instance.
    private static func createImageRequestOptions(deliveryMode: PHImageRequestOptionsDeliveryMode) -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode
        options.isSynchronous = false
        return options
    }
}
