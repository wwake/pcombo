@testable import pcombo
import XCTest

extension ParseResult {
  func successTarget() -> Target {
    guard case let .success(target, _) = self else {
      precondition(false, "result \(self) was not .success")
    }
    return target
  }

  func successRemaining() -> ArraySlice<Input> {
    guard case let .success(_, remaining) = self else {
      precondition(false, "result \(self) was not .success")
    }
    return remaining
  }
}

final class injectTests: XCTestCase {
    func testInjectsValueBeforeParser() {
      let one = satisfy { $0 == 1 }
      let parser = inject("string") <&> one
      let result = parser.parse([1,2])
      XCTAssertEqual(result.successTarget().0, "string")
      XCTAssertEqual(result.successTarget().1, 1)
      XCTAssertEqual(result.successRemaining(), [2])
    }
}
