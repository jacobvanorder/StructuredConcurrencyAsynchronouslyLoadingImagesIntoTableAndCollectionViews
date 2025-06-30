//
//  ImageURLRepository.swift
//  Async Image Loading
//
//  Created by Jacob Van Order on 7/1/25.
//  Copyright © 2025 Not Apple. All rights reserved.
//

import UIKit

/// A protocol used to load an image from somewhere that uses the [repository pattern](https://www.avanderlee.com/swift/repository-design-pattern/)
public protocol ImageURLRepository: Actor {
    func loadImage(atURL url: URL) async throws -> UIImage
}

extension ImageURLRepository {
    static func image(fromData data: Data) throws -> UIImage {
        guard let validImage = UIImage(data: data) else { throw ImageURLRepositoryError.badImageData }
        return validImage
    }
}

enum ImageURLRepositoryError: Error {
    case badImageData
    case imageDataNotFound
}
