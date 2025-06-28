/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The ImageURLProtocol of the sample.
 */
import UIKit

// TODO: Convert to Swift 6 Safe Type
class ImageURLProtocol: URLProtocol {

    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!

    private static let queue = DispatchSerialQueue(label: "com.apple.imageLoaderURLProtocol")

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


        block = DispatchWorkItem(block: {
            if self.cancelledOrComplete == false {
                let fileURL = URL(fileURLWithPath: reqURL.path)
                if let data = try? Data(contentsOf: fileURL),
                   let httpResponse = HTTPURLResponse(url: reqURL,
                                                      statusCode: 200,
                                                      httpVersion: nil,
                                                      headerFields: nil) {
                    urlClient.urlProtocol(self,
                                          didReceive: httpResponse,
                                          cacheStoragePolicy: .allowed)
                    urlClient.urlProtocol(self, didLoad: data)
                    urlClient.urlProtocolDidFinishLoading(self)
                }
            }
            self.cancelledOrComplete = true
        })

        ImageURLProtocol.queue.asyncAfter(deadline: .now() + 3.0, execute: block)
    }

    final override func stopLoading() {
        // TODO: Convert to Swift 6 Safe Type
        /*
        ImageURLProtocol.queue.async {
            if self.cancelledOrComplete == false, let cancelBlock = self.block {
                cancelBlock.cancel()
                self.cancelledOrComplete = true
            }
        }
         */
    }

    static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageURLProtocol.classForCoder()]
        return  URLSession(configuration: config)
    }

}
