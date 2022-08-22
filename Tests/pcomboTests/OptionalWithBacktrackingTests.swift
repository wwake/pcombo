@testable import pcombo
import XCTest

final class OptionalWithBacktrackingTests: XCTestCase {
  let sat1 = satisfy {$0 == 1}

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
}
