@testable import pcombo
import XCTest

final class CommaTests: XCTestCase {

  public func testCommaMatchingOneItem() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&&> sat2

    let result = grammar.parse([1,3])

    guard case let .success(target, remaining) = result else {
      XCTFail("Result was \(result)")
      return
    }
    XCTAssertEqual(target.0, 1, "target.0")
    XCTAssertEqual(target.1.count, 0, "target.1")
    XCTAssertEqual(remaining, [3], "remaining")
  }

  public func testCommaMatchingMultipleItems() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&&> sat2

    let result = grammar.parse([1,2,1,3])

    guard case let .success(target, remaining) = result else {
      XCTFail("Result was \(result)")
      return
    }
    XCTAssertEqual(target.0, 1, "target.0")
    XCTAssertEqual(target.1[0].0, 2, "target.1[0]")
    XCTAssertEqual(target.1[0].1, 1, "target.1[1]")
    XCTAssertEqual(remaining, [3], "remaining")
  }

  public func testCommaFailsToMatchFirstItem() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&&> sat2

    let result = grammar.parse([2,1,2,3])

    guard case let .failure(position, message) = result else {
      XCTFail("Result was \(result)")
      return
    }

    XCTAssertEqual(position, 0)
    XCTAssertEqual(message, "Did not find expected value")
  }

  public func testCommaLeftMatchingOneItem() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&& sat2

    let result = grammar.parse([1,3])

    result.checkSuccess([1], [3])
  }

  public func testCommaLeftMatchingMultipleItems() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&& sat2

    let result = grammar.parse([1,2,1,3])

    result.checkSuccess([1, 1], [3])
  }

  public func testCommaLeftFailsToMatchFirstItem() {
    let sat1 = satisfy {$0 == 1}
    let sat2 = satisfy {$0 == 2}
    let grammar = sat1 <&& sat2

    let result = grammar.parse([2,1,2,3])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }
}
