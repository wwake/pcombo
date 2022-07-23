@testable import pcombo
import XCTest

final class AndThenTests: XCTestCase {

  func testAndThenArrayMatchesBothItems() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([1,2,5])

    checkSuccess(result, [1, 2], [5])
  }

  func testAndThenArrayFailsIfFirstItemFailsToMatch() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([42,2,5])

    checkFailure(result, .failure(0, "Did not find expected value"))
  }

  func testAndThenArrayFailsIfOnlyFirstItemMatches() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([1,4,5])

    checkFailure(result, .failure(1, "Did not find expected value"))
  }

  func testAndThenArrayOperator() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = sat1 <&> sat2

    let result = parser.parse([1,2,5])

    checkSuccess(result, [1, 2], [5])
  }

  func testAndThenTupleReturnsTupleForNonMatchingTypes() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = sat1 <&> (sat2 |> { Double($0) })

    let result = parser.parse([1,2,5])

    guard case let .success(target, remaining) = result else {
      XCTFail("Result was \(result)")
      return
    }
    XCTAssertEqual(target.0, 1, "target.0")
    XCTAssertEqual(target.1, 2.0, "target.1")
    XCTAssertEqual(remaining, [5], "remaining")
  }

  func testAndThenTupleFailsIfFirstParserFails() {
    let sat1 = satisfy<Int>("m1") { $0 == 1 }
    let sat2 = satisfy<Int>("m2") { $0 == 2 }
    let parser = sat1 <&> (sat2 |> { Double($0) })

    let actual = parser.parse([3,2,5])

    if case let .failure(location, message) = actual {
        XCTAssertEqual(location, 0)
        XCTAssertEqual(message, "m1")
        return
    }

    XCTFail("Expected failure but got \(actual)")
  }

  func testAndThenTupleFailsIfSecondParserFails() {
    let sat1 = satisfy<Int>("m1") { $0 == 1 }
    let sat2 = satisfy<Int>("m2") { $0 == 2 }
    let parser = sat1 <&> (sat2 |> { Double($0) })

    let actual = parser.parse([1,3,2,5])

    if case let .failure(location, message) = actual {
      XCTAssertEqual(location, 1)
      XCTAssertEqual(message, "m2")
      return
    }

    XCTFail("Expected failure but got \(actual)")
  }
}
