@testable import pcombo
import XCTest

final class OptionalTests: XCTestCase {

  func testOptionalWithMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <?>sat1

    let result = grammar.parse([1,2])

    checkSuccess(result, 1, [2])
  }

  func testOptionalThatFailsToMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let grammar = <?>sat1

    let result = grammar.parse([2])

    checkSuccess(result, nil, [2])
  }
}
