//
//  File.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

@testable import pcombo
import XCTest

final class ManyTests: XCTestCase {
  func testMany1WithNoMatchesReturnsEmptyArray() {
    let sat1 = satisfy {$0 == 1}
    let grammar = <*>sat1

    let result = grammar.parse([2,1,2])

    let emptyValues = [Int]()
    result.checkSuccess(emptyValues, [2,1,2])
  }

  func testManyWithOneMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <*>sat1

    let result = grammar.parse([1,2])

    result.checkSuccess([1], [2])
  }

  func testManyWithMultipleMatches() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <*>sat1

    let result = grammar.parse([1,1,2])

    result.checkSuccess([1,1], [2])
  }

  func testManyWithMultipleParsersMultipleMatches() throws {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = <*>(sat1 <|> sat2)

    let result = grammar.parse([1,1,2])

    result.checkSuccess([1,1,2], [])
  }
}
