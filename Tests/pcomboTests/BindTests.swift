@testable import pcombo
import XCTest

final class Tests: XCTestCase {
  func testBindFromConstructorDefinesParserImmediately() throws {
    let digit = satisfy { $0 == 1 }

    let number = Bind(digit.parse)

    let result = number.parse([1,2])

    checkSuccess(result, 1, [2])
  }

  func testBindFromFunctionCanDefineParserLaterForRecurion() throws {
    let digit = satisfy { $0 == 1 } |> { [ $0 ]}
    let minus = satisfy { $0 == 2 }

    let expr = Bind<Int, [Int]>()
    let parser = digit <|> minus <&> expr
    expr.bind(parser.parse)

    let result = expr.parse([2,2,1,9])

    checkSuccess(result, [2,2,1], [9])
  }

  // Semi-manual test - precondition check
//  func testBindWithNoFunctionBoundHasException() throws {
//    let digit = satisfy { $0 == 1 } |> { [ $0 ]}
//    let minus = satisfy { $0 == 2 }
//
//    let expr = Bind<Int, [Int]>()
//    let parser = digit <|> minus <&> expr
//    // Forget to call: expr.bind(parser.parse)
//
//    let result = parser.parse([2,2,1,9])
//  }

}
