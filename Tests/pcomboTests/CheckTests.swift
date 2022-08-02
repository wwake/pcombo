//
//  CheckTests.swift
//  
//
//  Created by Bill Wake on 8/2/22.
//

@testable import pcombo
import XCTest

final class CheckTests: XCTestCase {
  func sumShouldBeEven(_ values: [Int]) -> (Int, String)? {
    let sum = values.reduce(0, +)
    if sum.isMultiple(of: 2) { return nil }
    return (values.count, "sum was odd")
  }

  func testReturnsParseResultWhenCheckSucceeds() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one <&| sumShouldBeEven
    let result = parser.parse([1,1,1,1,2])
    checkSuccess(result, [1,1,1,1], [2])
  }

  func testReturnsFailureWhenCheckFails() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one <&| sumShouldBeEven
    let result = parser.parse([1,1,1,2])
    checkFailure(result, .failure(3, "sum was odd"))
  }

  func testReturnsFailureWhenParseFails() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one <&| sumShouldBeEven
    let result = parser.parse([2])
    checkFailure(result, .failure(0, "Did not find expected value"))
  }
}
