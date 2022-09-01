@testable import pcombo
import XCTest

final class peekTests: XCTestCase {

  func testPeekReturnsNilWhenItMatches() {
    let sat1 = satisfy {$0 == 1}
    let parser = peek(sat1)

    let result = parser.parse([1,2])

    result.checkSuccess(1, [1,2])
  }

  func testPeekReturnsFailureWhenItFailsToMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let parser = peek(sat1)

    let result = parser.parse([2,1])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }
}
