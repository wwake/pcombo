//
//  ErrorReportingTests.swift
//  
//
//  Created by Bill Wake on 7/20/22.
//

@testable import pcombo
import XCTest

final class ErrorReportingTests: XCTestCase {

  func testSatisfyFailureReturnsFailure() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let result = sat1.parse([2])

    if case let .failure(location, message) = result {
      XCTAssertEqual(location, 0)
      XCTAssertEqual(message, "Did not find expected value")
      return
    }
    XCTFail("didn't get expected failure; got \(result)")
  }

  func testSatisfyForNoInputReturnsFailure() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let result = sat1.parse([])

    if case let .failure(location, message) = result {
      XCTAssertEqual(location, 0)
      XCTAssertEqual(message, "Did not find expected value")
      return
    }
    XCTFail("didn't get expected failure; got \(result)")
  }

  func testAlternativesReportMostSuccessfulError() {
    let sat1 = satisfy("should be 1") { $0 == 1 }
    let sat2 = satisfy("should be 2") { $0 == 2 }
    let sat3 = satisfy("should be 3") { $0 == 3 }
    let grammar = sat1 <&> sat2 <|> sat3 <&> sat1
    let result = grammar.parse([1])

    if case let .failure(location, message) = result {
      XCTAssertEqual(location, 1)
      XCTAssertEqual(message, "should be 2")
      return
    }
    XCTFail("didn't get expected failure; got \(result)")
  }

  func testAlternativesReportSecondErrorIfLocationTied() {
    let sat1 = satisfy("should be 1") { $0 == 1 }
    let sat2 = satisfy("should be 2") { $0 == 2 }

    let grammar = sat1 <|> sat2
    let result = grammar.parse([3])

    if case let .failure(location, message) = result {
      XCTAssertEqual(location, 0)
      XCTAssertEqual(message, "should be 2")
      return
    }
    XCTFail("didn't get expected failure; got \(result)")
  }
}
