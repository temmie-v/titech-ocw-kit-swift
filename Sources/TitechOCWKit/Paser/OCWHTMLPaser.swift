//
//  OCWHTMLPaser.swift
//  
//
//  Created by nanashiki on 2023/03/30.
//

import Foundation
import SwiftSoup

enum OCWHTMLPaser {
    static func parse(html: String, courseId: String) throws -> OCWCourse {
        let doc: Document = try SwiftSoup.parse(html)
        
        let courseYearString = courseId.prefix(4)
        let courseYear = Int(courseYearString) ?? -1
        
        let titleString = try doc
            .select("div.page-title-area h3")
            .html()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let titleMatch = titleString.firstMatch(of: #/.+　(?<ja>.+)&nbsp;&nbsp;&nbsp;(?<en>.+)/#) else {
            throw TitechOCWError.invalidOCWCourseHtml
        }

        let periodString = try doc
            .select("dd.place")
            .html()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let periods = periodString.matches(of: #/(?<day>[日月火水木金土])(?<start>\d+)-(?<end>\d+)(?:\((?<location>[^()（）]+(\([^()（）]+\)[^()（）]*)*)\))?/#).map { match -> OCWCoursePeriod in
            OCWCoursePeriod(
                day: DayOfWeek.generateFromJapanese(str: String(match.output.day)),
                start: Int(String(match.output.start)) ?? -1,
                end: Int(String(match.output.end)) ?? -1,
                location: String(match.output.location ?? "")
            )
        }

        let dds = try doc
            .select("dl.dl-para-l dd")
        
        let termString = try dds[3].html().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "Q", with: "")

        let quarters: [Int]

        switch termString {
        case _ where termString.contains("-"):
            let range = termString.split(separator: "-").compactMap { Int($0) }
            quarters = Array(range[0] ... range[1])
        default:
            quarters = termString.split(separator: "・").compactMap { Int($0) }
        }

        return OCWCourse(
            nameJa: String(titleMatch.output.ja),
            nameEn: String(titleMatch.output.en),
            periods: periods,
            terms: quarters.map {
                OCWCourseTerm(year: courseYear, quarter: $0)
            }
        )
    }
}
