/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The ImageURLProtocol of the sample.
 */
import Foundation
import UIKit
import os

@preconcurrency // URLProtocol, introduced with iOS 2.0 is preconcurrency.
final class ImageURLAsyncProtocol: URLProtocol {

    private var asyncTask: Task<(), Never>?
    private let logger = Logger(subsystem: "com.example.async-image-loading.ImageURLProtocol",
                        category: "Loader")

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    class override func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        return false
    }

    final override func startLoading() {
        guard let reqURL = request.url, let urlClient = client else {
            return
        }

        self.asyncTask = Task { [weak self] in
            guard let self else { return }
            do {
                try Task.checkCancellation()
                try await Task.sleep(for: .randomSeconds(min: 0.5, max: 3.0))
                try Task.checkCancellation()
                let fileURL = URL(fileURLWithPath: reqURL.path)
                let data = try Data(contentsOf: fileURL)
                if let httpResponse = HTTPURLResponse(url: reqURL,
                                                      statusCode: 200,
                                                      httpVersion: nil,
                                                      headerFields: nil) {
                    urlClient.urlProtocol(self,
                                          didReceive: httpResponse,
                                          cacheStoragePolicy: .allowed)
                    urlClient.urlProtocol(self, didLoad: data)
                    urlClient.urlProtocolDidFinishLoading(self)
                }
            } catch {
                self.logger.debug("Error with load: \(error.localizedDescription)")
                urlClient.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    final override func stopLoading() {
        if let asyncTask {
            asyncTask.cancel()
        }
    }

    static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageURLAsyncProtocol.classForCoder()]
        return  URLSession(configuration: config)
    }

}

extension Duration {
    static func randomSeconds(min: Double, max: Double) -> Duration {
        return .seconds(Double.random(in: (min...max)))
    }
}
