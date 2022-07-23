//
//  NameTests.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

@testable import pcombo
import XCTest

final class NameTests: XCTestCase {
  func testNameNotUsedIfParserSucceeds() {
    let sat1 = satisfy { $0 == 1 }
    let sat2 = satisfy { $0 == 2 }
    let grammar = sat1 <|> sat2 <%> "should be 1 or 2"

    let result = grammar.parse([1])

    if case .success(let value, let remaining) = result {
      XCTAssertEqual(value, 1)
      XCTAssertEqual(remaining, [])
      return
    }
    XCTFail("should be .success(1,[]) but was \(result)")
  }

  func testNameIsUsedIfParserCompletelyFails() {
    let sat1 = satisfy { $0 == 1 }
    let sat2 = satisfy { $0 == 2 }
    let grammar = sat1 <&> sat2 <|> sat2 <&> sat2 <%> "should be 12 or 22"

    let result = grammar.parse([0])

    if case .failure(let location, let message) = result {
      XCTAssertEqual(location, 0)
      XCTAssertEqual(message, "should be 12 or 22")
      return
    }
    XCTFail("should be failure but was \(result)")
  }

  func testNameUsesOriginalFailureIfPartiallyParsed() {
    let sat1 = satisfy("should be 1") { $0 == 1 }
    let sat2 = satisfy("should be 2") { $0 == 2 }
    let grammar = sat1 <&> sat2 <|> sat2 <&> sat2 <%> "should be 12 or 22"

    let result = grammar.parse([1, 3])

    if case .failure(let location, let message) = result {
      XCTAssertEqual(location, 1)
      XCTAssertEqual(message, "should be 2")
      return
    }
    XCTFail("should be failure but was \(result)")
  }
}
