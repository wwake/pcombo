@testable import pcombo
import XCTest

final class CheckTests: XCTestCase {
  func sumShouldBeEven(_ values: [Int], _ remaining: ArraySlice<Int>) -> ParseResult<Int, String> {
    let sum = values.reduce(0, +)
    if sum.isMultiple(of: 2) { return .success("Result: \(sum)", remaining) }
    return .failure(values.count, "sum was odd")
  }

  func testReturnsParseResultWhenCheckSucceeds() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one |&> sumShouldBeEven
    let result = parser.parse([1,1,1,1,2])
    result.checkSuccess("Result: 4", [2])
  }

  func testReturnsFailureWhenCheckFails() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one |&> sumShouldBeEven
    let result = parser.parse([1,1,1,2])
    result.checkFailure(.failure(3, "sum was odd"))
  }

  func testReturnsFailureWhenParseFails() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one |&> sumShouldBeEven
    let result = parser.parse([2])
    result.checkFailure(.failure(0, "Did not find expected value"))
  }
}

