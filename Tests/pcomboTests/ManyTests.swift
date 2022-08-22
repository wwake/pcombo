//
//  File.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

@testable import pcombo
import XCTest

final class ManyTests: XCTestCase {
  let sat1 = satisfy("expected 1") {$0 == 1}
  let sat2 = satisfy("expected 2") {$0 == 2}

  func testMany1WithNoMatchesReturnsEmptyArray() {
    let grammar = <*>sat1

    let result = grammar.parse([2,1,2])

    let emptyValues = [Int]()
    result.checkSuccess(emptyValues, [2,1,2])
  }

  func testManyWithOneMatch() throws {
    let grammar = <*>sat1

    let result = grammar.parse([1,2])

    result.checkSuccess([1], [2])
  }

  func testManyWithMultipleMatches() throws {
    let grammar = <*>sat1

    let result = grammar.parse([1,1,2])

    result.checkSuccess([1,1], [2])
  }

  func testManyWithMultipleParsersMultipleMatches() throws {
    let grammar = <*>(sat1 <|> sat2)

    let result = grammar.parse([1,1,2])

    result.checkSuccess([1,1,2], [])
  }

  func testManyThatPartiallyMatchesReturnsFailure() throws {
    let grammar = <*>(sat1 <&> sat2)

    let result = grammar.parse([1,1,2])

    result.checkFailure(.failure(1, "expected 2"))
  }
}
