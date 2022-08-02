@testable import pcombo
import XCTest

final class AndThenTests: XCTestCase {
  let sat1 = satisfy<Int> { $0 == 1 }
  let sat2 = satisfy<Int> { $0 == 2 }
  let sat3 = satisfy<Int> { $0 == 3 }
  let sat4 = satisfy<Int> { $0 == 4 }

  func testAndThenArrayMatchesBothItems() throws {
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([1,2,5])

    result.checkSuccess([1, 2], [5])
  }

  func testAndThenArrayFailsIfFirstItemFailsToMatch() throws {
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([42,2,5])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testAndThenArrayFailsIfOnlyFirstItemMatches() throws {
    let parser = AndThenArray<satisfy<Int>>(sat1, sat2)

    let result = parser.parse([1,4,5])

    result.checkFailure(.failure(1, "Did not find expected value"))
  }

  func testAndThenArrayOperator() throws {
    let parser = sat1 <&> sat2

    let result = parser.parse([1,2,5])

    result.checkSuccess([1, 2], [5])
  }

  func testAndThenTupleReturnsTupleForNonMatchingTypes() throws {
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

  func testAndThenArrayElementYieldsArray() throws {
    let parser = sat1 <&> sat2 <&> sat3

    let result = parser.parse([1,2,3,4])

    result.checkSuccess([1, 2, 3], [4])
  }

  func testAndThenArrayElementFailsIfFirstItemFailsToMatch() throws {
    let parser = (sat1 <&> sat2) <&> sat3

    let result = parser.parse([1,42,3])

    result.checkFailure(.failure(1, "Did not find expected value"))
  }

  func testAndThenArrayElementFailsIfOnlyFirstItemMatches() throws {
    let parser = (sat1 <&> sat2) <&> sat3

    let result = parser.parse([1,2,5])

    result.checkFailure(.failure(2, "Did not find expected value"))
  }

  func testAndThenElementArrayYieldsArray() throws {
    let parser = sat1 <&> (sat2 <&> sat3)

    let result = parser.parse([1,2,3,4])

    result.checkSuccess([1, 2, 3], [4])
  }

  func testAndThenElementArrayFailsIfFirstItemFailsToMatch() throws {
    let parser = sat1 <&> (sat2 <&> sat3)

    let result = parser.parse([42,2,3])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testAndThenElementArrayFailsIfOnlyFirstItemMatches() throws {
    let parser = sat1 <&> (sat2 <&> sat3)

    let result = parser.parse([1,2,5])

    result.checkFailure(.failure(2, "Did not find expected value"))
  }

  func testAndThenArrayArrayYieldsArrayOfArrays() throws {
    let parser = (sat1 <&> sat2) <&> (sat3 <&> sat4)

    let result = parser.parse([1,2,3,4,5])

    result.checkSuccess([[1, 2], [3, 4]], [5])
  }

  func testAndThenKeepLeftYieldsLeft() throws {
    let parser = sat1 <& sat2

    let result = parser.parse([1,2,3])

    result.checkSuccess(1, [3])
  }

  func testAndThenKeepLeftFailsIfFirstItemFailsToMatch() throws {
    let parser = sat1 <& sat2

    let result = parser.parse([11,2,3])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testAndThenKeepLeftFailsIfSecondItemFailsToMatch() throws {
    let parser = sat1 <& sat2

    let result = parser.parse([1,22,3])

    result.checkFailure(.failure(1, "Did not find expected value"))
  }

  func testAndThenKeepRightYieldsRight() throws {
    let parser = sat1 &> sat2

    let result = parser.parse([1,2,3])

    result.checkSuccess(2, [3])
  }

  func testAndThenKeepRightFailsIfFirstItemFailsToMatch() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }

    let parser = sat1 &> sat2

    let result = parser.parse([11,2,3])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testAndThenKeepRightFailsIfSecondItemFailsToMatch() throws {
    let parser = sat1 &> sat2

    let result = parser.parse([1,22,3])

    result.checkFailure(.failure(1, "Did not find expected value"))
  }
}
