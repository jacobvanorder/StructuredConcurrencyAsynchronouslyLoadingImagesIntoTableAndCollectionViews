/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The Image cache.
*/
import UIKit
import Foundation

public actor ImageCacheActor {

    static let publicCache = {
        let repository: ImageURLRepository
        repository = ImageURLMockRepository(delayedBetween: 0.5, and: 3.0)
        // Wanna see live data? Comment out the repository above and uncomment out this version below.
//        repository = ImageURLNetworkRepository()
        return ImageCacheActor(repository: repository)
    }()
    static let placeholderImage = UIImage(systemName: "rectangle")!
    static let brokenImage = UIImage(systemName: "rectangle.slash")!

    /// This isn't exactly Sendable so we'll see!
    @MainActor
    private let cachedImages = NSCache<NSURL, UIImage>()
    /// This replaces the dictionary that had the closure returning the item and UIImage when complete.
    /// Instead, we'll hold the tasks that we can cancel if we need to.
    private var loadingResponses = [URL: Task<(UIImage), any Error>]()
    private let repository: ImageURLRepository

    @MainActor
    public final func cachedImage(atURL url: URL) -> UIImage? {
        return cachedImages.object(forKey: url as NSURL)
    }

    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(imageAtURL url: URL) async throws -> UIImage {
        // Why the defer? The task will hold on to the value so let's nil that out and let the cache do it's job.
        defer { loadingResponses.removeValue(forKey: url) }
        // Check for a cached image.
        if let cachedImage = await cachedImage(atURL: url) {
            return cachedImage
        }
        // In case there are more than one requestor for the image, we wait for the previous request and
        // return the image (or throw)
        if let previousTask = loadingResponses[url] {
            return try await previousTask.value
        }

        // Go fetch the image.
        let currentTask = Task {
            let image = try await repository.loadImage(atURL: url)
            // Cache the image.
            await setCachedImage(image, atURL: url)
            return image
        }
        // We will save the Task in case another request comes for the same URL.
        loadingResponses[url] = currentTask
        return try await currentTask.value
    }

    @MainActor
    private func setCachedImage(_ cachedImage: UIImage, atURL url: URL) {
        cachedImages.setObject(cachedImage, forKey: url as NSURL)
    }

    init(repository: ImageURLRepository) {
        self.repository = repository
    }
}
