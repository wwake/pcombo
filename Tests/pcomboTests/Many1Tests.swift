//
//  Many1Tests.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

@testable import pcombo
import XCTest

final class Many1Tests: XCTestCase {
  func testMany1WithOneMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <+>sat1

    let result = grammar.parse([1,2])

    result.checkSuccess([1], [2])
  }

  func testMany1WithMultipleMatches() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <+>sat1

    let result = grammar.parse([1,1,2])

    result.checkSuccess([1,1], [2])
  }

  func testMany1WithMultipleParsersMultipleMatches() throws {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = <+>(sat1 <|> sat2)

    let result = grammar.parse([1,1,2,3])

    result.checkSuccess([1,1,2], [3])
  }

  func testMany1WithNoMatchesReturnsFailure() {
    let sat1 = satisfy {$0 == 1}
    let grammar = <+>sat1

    let result = grammar.parse([2,1,2])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }
}
