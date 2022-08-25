import XCTest
@testable import TitechOCWKit

final class TitechOCWKitTests: XCTestCase {
    func testFetchOCWCourseFor202201977() async throws {
        let html = try! String(contentsOf: Bundle.module.url(forResource: "202201977", withExtension: "html")!)
        let course = try await TitechOCW(mockHTML: html).fetchOCWCourse(courseId: "202201977")
        
        XCTAssertEqual(
            course,
            OCWCourse(
                nameJa: "計算アルゴリズムとプログラミング",
                nameEn: "Computation Algorithms and Programming",
                periods: [
                    .init(day: .tuesday, start: 5, end: 6, location: "W933"),
                    .init(day: .friday, start: 5, end: 6, location: "W933")
                ],
                terms: [
                    .init(year: 2022, quarter: 2)
                ]
            )
        )
    }
    
    func testFetchOCWCourseFor202206894() async throws {
        let html = try! String(contentsOf: Bundle.module.url(forResource: "202206894", withExtension: "html")!)
        let course = try await TitechOCW(mockHTML: html).fetchOCWCourse(courseId: "202206894")
        
        XCTAssertEqual(
            course,
            OCWCourse(
                nameJa: "VLSI工学第一",
                nameEn: "VLSI Technology I",
                periods: [
                    .init(day: .monday, start: 1, end: 2, location: ""),
                    .init(day: .thursday, start: 1, end: 2, location: "")
                ],
                terms: [
                    .init(year: 2022, quarter: 1)
                ]
            )
        )
    }
    
    func testFetchOCWCourseFor202200304() async throws {
        let html = try! String(contentsOf: Bundle.module.url(forResource: "202200304", withExtension: "html")!)
        let course = try await TitechOCW(mockHTML: html).fetchOCWCourse(courseId: "202200304")
        
        XCTAssertEqual(
            course,
            OCWCourse(
                nameJa: "化学実験第一 A",
                nameEn: "Chemistry Laboratory I A",
                periods: [
                    .init(day: .monday, start: 7, end: 10, location: "W521")
                ],
                terms: [
                    .init(year: 2022, quarter: 1),
                    .init(year: 2022, quarter: 2)
                ]
            )
        )
    }

    func testFetchOCWCourseFor202202559() async throws {
        let html = try! String(contentsOf: Bundle.module.url(forResource: "202202559", withExtension: "html")!)
        let course = try await TitechOCW(mockHTML: html).fetchOCWCourse(courseId: "202202559")
        
        XCTAssertEqual(
            course,
            OCWCourse(
                nameJa: "建築設計製図第三",
                nameEn: "Architectural Design and Drawing III",
                periods: [
                    .init(day: .tuesday, start: 2, end: 4, location: "建築製図室W9-511設計製図室"),
                    .init(day: .thursday, start: 5, end: 7, location: "建築製図室W9-511設計製図室")],
                terms: [
                    .init(year: 2022, quarter: 1),
                    .init(year: 2022, quarter: 3)
                ]
            )
        )
    }
}
