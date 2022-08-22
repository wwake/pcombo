@testable import pcombo
import XCTest

final class OptionalTests: XCTestCase {
  let sat1 = satisfy("expected 1") {$0 == 1}
  let sat2 = satisfy("expected 2") {$0 == 2}

  func testOptionalWithMatchReturnsMatchedItem() throws {
    let grammar = <?>sat1

    let result = grammar.parse([1,2])

    result.checkSuccess(1, [2])
  }

  func testOptionalThatTotallyFailsToMatchReturnsNil() throws {
    let grammar = <?>sat1

    let result = grammar.parse([2])

    result.checkSuccess(nil, [2])
  }

  func testOptionalThatPartiallyFailsToMatchReturnsFailure() throws {
    let grammar = <?>(sat1 <&> sat2)

    let result = grammar.parse([1,3])

    result.checkFailure(.failure(1, "expected 2"))
  }
}

final class OptionalWithBacktrackingTests: XCTestCase {
  let sat1 = satisfy("expected 1") {$0 == 1}
  let sat2 = satisfy("expected 2") {$0 == 2}

  func testOptionalWithMatch() throws {
    let grammar = <??>sat1

    let result = grammar.parse([1,2])

    result.checkSuccess(1, [2])
  }

  func testOptionalThatFailsToMatch() throws {
    let grammar = <??>sat1

    let result = grammar.parse([2])

    result.checkSuccess(nil, [2])
  }

  func testOptionalThatPartiallyFailsToMatchStillReturnsNil() throws {
    let grammar = <??>(sat1 <&> sat2)

    let result = grammar.parse([1,3])

    result.checkSuccess(nil, [1,3])
  }
}
