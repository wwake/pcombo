@testable import pcombo
import XCTest

final class peekTests: XCTestCase {

  func testPeekReturnsNilWhenItMatches() {
    let sat1 = satisfy {$0 == 1}
    let parser = peek(sat1)

    let result = parser.parse([1,2])

    guard case let .success(target, remaining) = result else {
      XCTFail("Result was \(result)")
      return
    }
    XCTAssertEqual(target, 0, "target")
    XCTAssertEqual(remaining, [1,2], "remaining")
  }

  func testPeekReturnsFailureWhenItFailsToMatch() throws {
    let sat1 = satisfy {$0 == 1}
    let parser = peek(sat1)

    let result = parser.parse([2,1])

    guard case let .failure(location, message) = result else {
      XCTFail("Result was \(result)")
      return
    }
    XCTAssertEqual(location, 0)
    XCTAssertEqual(message, "Did not find expected value")
  }
}
