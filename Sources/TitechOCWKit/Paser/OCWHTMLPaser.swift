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
        let courseYear = Int(courseYearString)!
        
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
        let periodRegexpResult = periodString.matches("([日月火水木金土])(\\d+)-(\\d+)(?:\\(([^)]*)\\))?") ?? []

        let periods = periodRegexpResult.map { result -> OCWCoursePeriod in
            OCWCoursePeriod(
                day: DayOfWeek.generateFromJapanese(str: result[0]),
                start: Int(result[1]) ?? -1,
                end: Int(result[2]) ?? -1,
                location: result[3]
            )
        }

        let dds = try doc
            .select("dl.dl-para-l dd")
        
        let termString = try dds[3].html().trimmingCharacters(in: .whitespacesAndNewlines)

        let quarters: [Int]

        if termString.contains("-") {
            if let termRegexpResult = termString.matches("(\\d+)-(\\d+)Q") {
                let start = Int(termRegexpResult[0][0])!
                let end = Int(termRegexpResult[0][1])!
                
                quarters = (start ... end).map { $0 }
            } else {
                quarters = []
            }
        } else if termString.contains("・") {
            if let termRegexpResult = termString.matches("(\\d+)・(\\d+)Q") {
                let q1 = Int(termRegexpResult[0][0])!
                let q2 = Int(termRegexpResult[0][1])!
                
                quarters = [q1, q2]
            } else {
                quarters = []
            }
        } else {
            quarters = [Int(termString.replacingOccurrences(of: "Q", with: ""))!]
        }

        return OCWCourse(
            nameJa: titleArr[0][0],
            nameEn: titleArr[0][1],
            periods: periods,
            terms: quarters.map {
                OCWCourseTerm(year: courseYear, quarter: $0)
            }
        )
    }
}
