import XCTest
@testable import pcombo

final class OrElseTests: XCTestCase {
  let sat1 = satisfy<Int>("expected 1") { $0 == 1 }
  let sat2 = satisfy<Int>("expected 2") { $0 == 2 }
  let sat3 = satisfy<Int>("expected 3") { $0 == 3 }

  func testOrElseCanMatchFirstItem() throws {
    let parser = sat1 <|> sat2

    let result = parser.parse([1,4,5])

    result.checkSuccess(1, [4,5])
  }

  func testOrElseFailsIfFirstParserPartiallyMatches() throws {
    let parser = (sat1 <&> sat3) <|> (sat1 <&> sat2)

    let result = parser.parse([1,2,3,4])

    result.checkFailure(.failure(1, "expected 3"))
  }

  func testOrElseCanMatchSecondItemIfFirstParserGetsNowhere() throws {
    let parser = sat1 <|> sat2

    let result = parser.parse([2,4,5])

    result.checkSuccess(2, [4,5])
  }

  func testOrElseFailsToMatch() throws {
    let parser = sat1 <|> sat2

    let result = parser.parse([3,4,5])

    result.checkFailure(.failure(0, "expected 2"))
  }
}

final class OrElseWithBacktrackingTests: XCTestCase {
  let sat1 = satisfy<Int>("expected 1") { $0 == 1 }
  let sat2 = satisfy<Int>("expected 2") { $0 == 2 }
  let sat3 = satisfy<Int>("expected 3") { $0 == 3 }

  func testOrElseCanMatchFirstItem() throws {
    let parser = sat1 <||> sat2

    let result = parser.parse([1,4,5])

    result.checkSuccess(1, [4,5])
  }

  func testOrElseCanMatchSecondItem() throws {
    let parser = sat1 <||> sat2

    let result = parser.parse([2,4,5])

    result.checkSuccess(2, [4,5])
  }

  func testOrElseFailsToMatch() throws {
    let parser = sat1 <||> sat2

    let result = parser.parse([3,4,5])

    result.checkFailure(.failure(0, "expected 2"))
  }

  func testOrElseWithBacktrackingSucceedsEvenIfFirstParserPartiallyMatches() throws {
    let parser = (sat1 <&> sat3) <||> (sat1 <&> sat2)

    let result = parser.parse([1,2,3,4])

    result.checkSuccess([1,2], [3,4])
  }
}
