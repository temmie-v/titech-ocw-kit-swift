import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftSoup
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import NIOFoundationCompat

public enum TitechOCWError: Error {
    case invalidHTTPStatusCode(code: UInt)
    case invalidOCWCourseHtml
}

public struct TitechOCW {
    public static let defaultUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Safari/604.1"
    private let httpClient: HTTPClient
    private let userAgent: String

    public init(eventLoopGroup: any EventLoopGroup, userAgent: String = TitechOCW.defaultUserAgent) {
        self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        self.userAgent = userAgent
    }

    public func fetchOCWCourse(courseId: String) async throws -> OCWCourse {
        var request = HTTPClientRequest(url: "http://www.ocw.titech.ac.jp/index.php?module=General&action=T0300&JWC=\(courseId)")
        request.headers = HTTPHeaders([
            ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"),
            ("Accept-Language", "ja-jp"),
            ("User-Agent", userAgent)
        ])

        let response = try await httpClient.execute(request, timeout: .seconds(30))

        if response.status == .ok {
            let byteBuffer = try await response.body.collect(upTo: .max)
            let data = byteBuffer.getData(at: 0, length: byteBuffer.readableBytes)
            let html = String(data: data ?? Data(), encoding: .utf8) ?? ""
            return try OCWHTMLPaser.parse(html: html, courseId: courseId)
        } else {
            throw TitechOCWError.invalidHTTPStatusCode(code: response.status.code)
        }
    }

    public func shutdown() async throws {
        try await httpClient.shutdown()
    }
}
