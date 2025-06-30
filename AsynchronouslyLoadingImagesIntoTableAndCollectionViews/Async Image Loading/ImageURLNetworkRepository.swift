//
//  ImageURLNetworkRepository.swift
//  Async Image Loading
//
//  Created by Jacob Van Order on 7/1/25.
//  Copyright © 2025 Not Apple. All rights reserved.
//

import UIKit

/// Our network version of the repository that takes in a base url and optional image directory path and `URLSession`.
actor ImageURLNetworkRepository: ImageURLRepository {

    let urlSession: URLSession

    func loadImage(atURL url: URL) async throws -> UIImage {
        let (data, response) = try await urlSession.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode != 404 else { throw ImageURLRepositoryError.imageDataNotFound }
        return try Self.image(fromData: data)
    }

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}
