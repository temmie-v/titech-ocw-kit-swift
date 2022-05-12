import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftSoup

enum TitechOCWError: Error {
    case invalidOCWCourseHtml
}

public struct TitechOCW {
    public static let defaultUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1"
    private let urlSession: URLSession
    private let userAgent: String
    
    public init(urlSession: URLSession = .shared, userAgent: String = TitechOCW.defaultUserAgent) {
        self.urlSession = urlSession
        self.userAgent = userAgent
    }

    public func fetchOCWCourse(courseId: String) async throws -> OCWCourse {
        let data = try await fetchData(url: URL(string: "http://www.ocw.titech.ac.jp/index.php?module=General&action=T0300&JWC=\(courseId)")!)
        
        let doc: Document = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
        
        let titleString = try doc
            .select("div.page-title-area h3")
            .html()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let titleArr = titleString.matches(".+　(.+)&nbsp;&nbsp;&nbsp;(.+)"), titleArr.count == 1, titleArr[0].count == 2 else {
            throw TitechOCWError.invalidOCWCourseHtml
        }

        let periodString = try doc
            .select("dd.place")
            .html()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let periodRegexpResutl = periodString.matches("(.)(\\d+)-(\\d+)(?:\\(([^)]*)\\))?") ?? []

        let periods = periodRegexpResutl.map { result -> OCWCoursePeriod in
            OCWCoursePeriod(
                day: DayOfWeek.generateFromJapanese(str: result[0]),
                start: Int(result[1]) ?? -1,
                end: Int(result[2]) ?? -1,
                location: result[3]
            )
        }
        
        return OCWCourse(nameJa: titleArr[0][0], nameEn: titleArr[0][1], periods: periods)
    }
    
    func fetchData(url: URL) async throws -> Data {
        var reqest = URLRequest(url: url)
        reqest.allHTTPHeaderFields = [
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Encoding": "br, gzip, deflate",
            "Accept-Language": "ja-jp",
            "User-Agent" : userAgent
        ]
        #if canImport(FoundationNetworking)
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(with: reqest) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data ?? Data())
                }
            }.resume()
        }
        #else
        let (data, _) = try await urlSession.data(for: reqest)
        return data
        #endif
    }
}


public struct OCWCourse: Equatable, Codable {
    public let nameJa: String
    public let nameEn: String
    public let periods: [OCWCoursePeriod]
}

public struct OCWCoursePeriod: Equatable, Codable {
    public let day: DayOfWeek
    public let start: Int
    public let end: Int
    public let location: String
}

public enum DayOfWeek: Int, Codable, CaseIterable, Equatable {
    case unknown = 0
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    static func generateFromJapanese(str: String) -> DayOfWeek {
        if str.contains("日") {
            return .sunday
        } else if str.contains("月") {
            return .monday
        } else if str.contains("火") {
            return .tuesday
        } else if str.contains("水") {
            return .wednesday
        } else if str.contains("木") {
            return .thursday
        } else if str.contains("金") {
            return .friday
        } else if str.contains("土") {
            return .saturday
        } else {
            return .unknown
        }
    }

    static func generateFromEnglish(str: String) -> DayOfWeek {
        if str.contains("Sun") {
            return .sunday
        } else if str.contains("Mon") {
            return .monday
        } else if str.contains("Tue") {
            return .tuesday
        } else if str.contains("Wed") {
            return .wednesday
        } else if str.contains("Thu") {
            return .thursday
        } else if str.contains("Fri") {
            return .friday
        } else if str.contains("Sat") {
            return .saturday
        } else {
            return .unknown
        }
    }
}

