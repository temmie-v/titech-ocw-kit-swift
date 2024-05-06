import XCTest
@testable import TitechOCWKit
import NIOCore
// import NIOTransportServices

final class OCWHTMLPaserTests: XCTestCase {
//    func testParseFor202304063() async throws {
//        let titechOCW = TitechOCW(eventLoopGroup: NIOTSEventLoopGroup())
//        _ = try await titechOCW.fetchOCWCourse(courseId: "202304063")
//        try await titechOCW.shutdown()
//    }

    func testParseFor202201977() throws {
        let html = try! String(contentsOf: Bundle.module.url(forResource: "202201977", withExtension: "html")!)
        let course = try OCWHTMLPaser.parse(html: html, courseId: "202201977")
        print(course)
        
        XCTAssertEqual(
            course,
            OCWCourse(ocwId: 202201977, courseNumber: "EEE.M221", titleJa: "計算アルゴリズムとプログラミング", titleEn: "Computation Algorithms and Programming", year: 2022, startQuarter: 2, endQuarter: 2, teachers: ["庄司 雄哉", "間中 孝彰"], departments: ["電気電子系"])
        )
    }
//    
//    func testParseFor202206894() throws {
//        let html = try! String(contentsOf: Bundle.module.url(forResource: "202206894", withExtension: "html")!)
//        let course = try OCWHTMLPaser.parse(html: html, courseId: "202206894")
//        
//        XCTAssertEqual(
//            course,
//            OCWCourse(
//                nameJa: "VLSI工学第一",
//                nameEn: "VLSI Technology I",
//                periods: [
//                    .init(day: .monday, start: 1, end: 2, location: ""),
//                    .init(day: .thursday, start: 1, end: 2, location: "")
//                ],
//                terms: [
//                    .init(year: 2022, quarter: 1)
//                ]
//            )
//        )
//    }
//    
//    func testParseFor202200304() throws {
//        let html = try! String(contentsOf: Bundle.module.url(forResource: "202200304", withExtension: "html")!)
//        let course = try OCWHTMLPaser.parse(html: html, courseId: "202200304")
//        
//        XCTAssertEqual(
//            course,
//            OCWCourse(
//                nameJa: "化学実験第一 A",
//                nameEn: "Chemistry Laboratory I A",
//                periods: [
//                    .init(day: .monday, start: 7, end: 10, location: "W521")
//                ],
//                terms: [
//                    .init(year: 2022, quarter: 1),
//                    .init(year: 2022, quarter: 2)
//                ]
//            )
//        )
//    }
//
//    func testParseFor202202559() throws {
//        let html = try! String(contentsOf: Bundle.module.url(forResource: "202202559", withExtension: "html")!)
//        let course = try OCWHTMLPaser.parse(html: html, courseId: "202202559")
//        
//        XCTAssertEqual(
//            course,
//            OCWCourse(
//                nameJa: "建築設計製図第三",
//                nameEn: "Architectural Design and Drawing III",
//                periods: [
//                    .init(day: .tuesday, start: 2, end: 4, location: "建築製図室W9-511設計製図室"),
//                    .init(day: .thursday, start: 5, end: 7, location: "建築製図室W9-511設計製図室")],
//                terms: [
//                    .init(year: 2022, quarter: 1),
//                    .init(year: 2022, quarter: 3)
//                ]
//            )
//        )
//    }
//    
//    func testParseFor202202207() throws {
//        let html = try! String(contentsOf: Bundle.module.url(forResource: "202202207", withExtension: "html")!)
//        let course = try OCWHTMLPaser.parse(html: html, courseId: "202202207")
//        
//        XCTAssertEqual(
//            course,
//            OCWCourse(
//                nameJa: "有機機能材料物理",
//                nameEn: "Organic Functional Materials Physics",
//                periods: [],
//                terms: [
//                    .init(year: 2022, quarter: 3)
//                ]
//            )
//        )
//    }
//    
//    func testParseFor202335143() throws {
//        let html = try! String(contentsOf: Bundle.module.url(forResource: "202335143", withExtension: "html")!)
//        let course = try OCWHTMLPaser.parse(html: html, courseId: "202335143")
//        
//        XCTAssertEqual(
//            course,
//            OCWCourse(
//                nameJa: "世界を知る：ヨーロッパ 1",
//                nameEn: "Area Studies: Europe 1",
//                periods: [.init(day: .wednesday, start: 3, end: 4, location: "SL-101(S011)")],
//                terms: [
//                    .init(year: 2023, quarter: 1)
//                ]
//            )
//        )
//    }
}
