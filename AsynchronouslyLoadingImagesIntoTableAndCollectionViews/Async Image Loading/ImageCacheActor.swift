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
//        repository = ImageURLNetworkRepository(baseURL: URL(string: "https://www.jacobvanorder.com")!)
        return ImageCacheActor(repository: repository)
    }()
    static let placeholderImage = UIImage(systemName: "rectangle")!
    static let brokenImage = UIImage(systemName: "rectangle.slash")!

    /// This isn't exactly Sendable so we'll see!
    @MainActor
    private let cachedImages = NSCache<NSString, UIImage>()
    /// This replaces the dictionary that had the closure returning the item and UIImage when complete.
    /// Instead, we'll hold the tasks that we can cancel if we need to.
    private var loadingResponses = [String: Task<(UIImage), any Error>]()
    private let repository: ImageURLRepository

    @MainActor
    public final func image(named name: String) -> UIImage? {
        return cachedImages.object(forKey: name as NSString)
    }

    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(imageNamed name: String) async throws -> UIImage {
        // Why the defer? The task will hold on to the value so let's nil that out and let the cache do it's job.
        defer { loadingResponses.removeValue(forKey: name) }
        // Check for a cached image.
        if let cachedImage = await image(named: name) {
            return cachedImage
        }
        // In case there are more than one requestor for the image, we wait for the previous request and
        // return the image (or throw)
        if let previousTask = loadingResponses[name] {
            return try await previousTask.value
        }

        // Go fetch the image.
        let currentTask = Task {
            let image = try await repository.loadImage(named: name)
            // Cache the image.
            await setCachedImage(image, named: name)
            return image
        }
        // We will save the Task in case another request comes for the same URL.
        loadingResponses[name] = currentTask
        return try await currentTask.value
    }

    @MainActor
    private func setCachedImage(_ cachedImage: UIImage, named name: String) {
        cachedImages.setObject(cachedImage, forKey: name as NSString)
    }

    init(repository: ImageURLRepository) {
        self.repository = repository
    }
}
