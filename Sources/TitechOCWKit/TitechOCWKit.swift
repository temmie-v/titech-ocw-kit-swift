import Foundation
import Kanna

enum TitechOCWError: Error {
    case invalidOCWCourseHtml
}

public enum TitechOCW {
    public static func fetchOCWCourse(courseId: String) async throws -> OCWCourse {
        let data = try await fetchData(url: URL(string: "http://www.ocw.titech.ac.jp/index.php?module=General&action=T0300&GakubuCD=2&GakkaCD=321700&KeiCD=17&KougiCD=\(courseId)&Nendo=2022&lang=JA&vid=03")!)
        
        let html = try HTML(html: data, encoding: .utf8)
        
        let titleString = html.css("div.page-title-area h3")
            .compactMap {
                $0.innerHTML?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .first
        guard let titleArr = titleString?.matches(".+　(.+)   (.+)") else {
            throw TitechOCWError.invalidOCWCourseHtml
        }
            
        
        let periodString = html.css("dd.place")
            .compactMap {
                $0.innerHTML?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .first
        let periodRegexpResutl = periodString?.matches("(.)(\\d+)-(\\d+)(?:\\(([^)]*)\\))?") ?? []
        
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
    
    static func fetchData(url: URL) async throws -> Data {
        #if canImport(FoundationNetworking)
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: data!)
            }.resume()
        }
        #else
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
        #endif
    }
}


public struct OCWCourse: Equatable {
    public let nameJa: String
    public let nameEn: String
    public let periods: [OCWCoursePeriod]
}

public struct OCWCoursePeriod: Equatable {
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

