import XCTest
@testable import pcombo

final class OrElseTests: XCTestCase {

  func testOrElseCanMatchFirstItem() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = OrElse<satisfy<Int>, satisfy<Int>>(sat1, sat2)

    let result = parser.parse([1,4,5])

    result.checkSuccess(1, [4,5])
  }

  func testOrElseCanMatchSecondItem() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = OrElse<satisfy<Int>, satisfy<Int>>(sat1, sat2)

    let result = parser.parse([2,4,5])

    result.checkSuccess(2, [4,5])
  }

  func testOrElseFailsToMatch() throws {
    let sat1 = satisfy<Int> { $0 == 1 }
    let sat2 = satisfy<Int> { $0 == 2 }
    let parser = OrElse<satisfy<Int>, satisfy<Int>>(sat1, sat2)

    let result = parser.parse([3,4,5])

    result.checkFailure(.failure(0, "Did not find expected value"))
  }

  func testOrElseOperator() throws {
    let sat1 = satisfy { $0 == 1 }
    let sat2 = satisfy { $0 == 2 }
    let parser = sat1 <|> sat2

    let result = parser.parse([2,4,5])

    result.checkSuccess(2, [4,5])
  }
}
