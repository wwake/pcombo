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

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testSatisfyForNoInputReturnsFailure() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let result = sat1.parse([])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testAlternativesReportMostSuccessfulError() {
    let sat1 = satisfy("should be 1") { $0 == 1 }
    let sat2 = satisfy("should be 2") { $0 == 2 }
    let sat3 = satisfy("should be 3") { $0 == 3 }
    let grammar = sat1 <&> sat2 <||> sat3 <&> sat1
    let result = grammar.parse([1])

    result.checkFailure(.failure(1, "should be 2"))
  }

  func testAlternativesReportSecondErrorIfLocationTied() {
    let sat1 = satisfy("should be 1") { $0 == 1 }
    let sat2 = satisfy("should be 2") { $0 == 2 }

    let grammar = sat1 <||> sat2
    let result = grammar.parse([3])

    result.checkFailure(.failure(0, "should be 2"))
  }
}
