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

    let baseURL: URL
    let imageDirPath: String
    let urlSession: URLSession

    func loadImage(named name: String) async throws -> UIImage {
        let folderURL = self.baseURL.appending(path: imageDirPath, directoryHint: .isDirectory)
        let url = folderURL.appending(path: name)
        let (data, response) = try await urlSession.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode != 404 else { throw ImageURLRepositoryError.imageDataNotFound }
        return try Self.image(fromData: data)
    }

    init(baseURL: URL,
         imageDirPath: String = "async-Image-loading/images",
         urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.imageDirPath = imageDirPath
        self.urlSession = urlSession
    }
}
