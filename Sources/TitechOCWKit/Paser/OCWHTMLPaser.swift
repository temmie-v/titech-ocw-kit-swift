//
//  OCWHTMLPaser.swift
//  
//
//  Created by nanashiki on 2023/03/30.
//

import Foundation
import SwiftSoup

// get: ocwId, courseNumber, name(J/E), year, startQ, endQ, departments, teacher(J/E)

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

//        let periodString = try doc
//            .select("dd.place")
//            .html()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        let periods = periodString.matches(of: #/(?<day>[日月火水木金土])(?<start>\d+)-(?<end>\d+)(?:\((?<location>[^()（）]+(\([^()（）]+\)[^()（）]*)*)\))?/#).map { match -> OCWCoursePeriod in
//            OCWCoursePeriod(
//                day: DayOfWeek.generateFromJapanese(str: String(match.output.day)),
//                start: Int(String(match.output.start)) ?? -1,
//                end: Int(String(match.output.end)) ?? -1,
//                location: String(match.output.location ?? "")
//            )
//        }
        
        let dep = try doc.select("dl dd")
        let deps = try dep[0].html().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let teachersdoc = try doc
            .select("dl.clearfix dd a")
        var teachers: [String] = []
        for teacher in teachersdoc {
            let teacherName = try teacher.html().trimmingCharacters(in: .whitespacesAndNewlines)
            teachers.append(teacherName)
        }
        
        let dds = try doc
            .select("dl.dl-para-l dd")
        
        let courseNumber = try dds[0].html().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let termString = try dds[3].html().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "Q", with: "")

        let quarters: [Int]
        
        if (termString.contains("-")) {
            let range = termString.split(separator: "-").compactMap { Int($0) }
            quarters = Array(range[0] ... range[1])
        } else {
            quarters = termString.split(separator: "・").compactMap { Int($0) }
        }

        return OCWCourse(
            ocwId: Int(courseId) ?? -1,
            courseNumber: courseNumber,
            titleJa: String(titleMatch.output.ja),
            titleEn: String(titleMatch.output.en),
            year: courseYear,
            startQuarter: quarters.min() ?? 1,
            endQuarter: quarters.max() ?? 4,
            teachers: teachers,
            departments: [deps]
        )
    }
}
