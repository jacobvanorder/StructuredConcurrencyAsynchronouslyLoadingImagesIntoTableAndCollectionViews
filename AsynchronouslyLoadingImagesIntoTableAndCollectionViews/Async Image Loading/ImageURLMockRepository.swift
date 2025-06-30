//
//  ImageURLMockRepository.swift
//  Async Image Loading
//
//  Created by Jacob Van Order on 7/1/25.
//  Copyright © 2025 Not Apple. All rights reserved.
//

import UIKit

/// Our mock version of the repository that allows you to set a minimum and maximum amount of time to wait before it
/// goes to the optional bundle specified and fetches it from disk after the delay.
actor ImageURLMockRepository: ImageURLRepository {

    let delayRange: ClosedRange<Double>
    let bundle: Bundle

    func loadImage(named name: String) async throws -> UIImage {
        try await Task.sleep(for: .randomSeconds(in: delayRange))
        guard let bundleURL = bundle.url(forResource: name, withExtension: "") else { throw ImageURLRepositoryError.imageDataNotFound }
        let data = try Data(contentsOf: bundleURL)
        return try Self.image(fromData: data)
    }

    init(delayedBetween start: Double, and end: Double, bundle: Bundle = .main) {
        self.delayRange = start...end
        self.bundle = bundle
    }
}

private extension Duration {
    static func randomSeconds(in delayRange: ClosedRange<Double>) -> Duration {
        return .seconds(Double.random(in: delayRange))
    }
}
