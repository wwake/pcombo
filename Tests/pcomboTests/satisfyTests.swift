import XCTest
@testable import pcombo

final class satisfyTests: XCTestCase {

  func testSatisfyThatMatches() throws {
    let parser = satisfy<Int> { $0 == 3 }

    let result = parser.parse([3, 2, 1])

    checkSuccess(result, 3, [2,1])
  }

  func testSatisfyWithDefaultMessageThatFailsToMatch() throws {
    let parser = satisfy<Int> { $0 == -42}

    let result = parser.parse([3, 2, 1])

    checkFailure(result, .failure(0, "Did not find expected value"))
  }

  func testSatisfyWithMessageThatFailsToMatch() throws {
    let parser = satisfy<Int>("my message") { $0 == -42}

    let result = parser.parse([3, 2, 1])

    checkFailure(result, .failure(0, "my message"))
  }

  func testSatisfyWithDefaultMessageFailsOnEmptyInput() throws {
    let parser = satisfy<Int> { $0 == 3}

    let emptyInput = [0,1,2][3...]
    let result = parser.parse(emptyInput)

    checkFailure(result, .failure(3, "Did not find expected value"))
  }

  func testSatisfyWithMessageFailsOnEmptyInput() throws {
    let parser = satisfy<Int>("didn't find") { $0 == 3}

    let emptyInput = [0,1,2][3...]
    let result = parser.parse(emptyInput)

    checkFailure(result, .failure(3, "didn't find"))
  }
}
