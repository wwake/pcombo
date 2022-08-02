@testable import pcombo
import XCTest

indirect enum Statement: Equatable {
  case skip
  case other
  case ifStatement(Statement, Statement)
}

final class GrammarTests: XCTestCase {
  func buildIfStatement(_ argument: (Statement, Statement?)) -> Statement {
    let (thenClause, elseClause) = argument

    if let elseClause = elseClause {
      return .ifStatement(thenClause, elseClause)
    }

    return .ifStatement(thenClause, .skip)
  }

  func testDanglingElse() throws {
    let statement = Bind<String, Statement>()

    let otherStatement = satisfy{$0 == "other"} |> { _ in Statement.other }

    let ifClause = satisfy{$0 == "if"}
    let elseClause = satisfy{$0 == "else"}

    let ifStatement = ifClause &> statement <&> <?>(elseClause &> statement)

    let statements = otherStatement <|> (ifStatement |> buildIfStatement)

    statement.bind(statements.parse)

    //if expr1 then if expr2 then other1 else other2
    let result = statement.parse(["if", "if", "other", "else", "other"])

    guard case let .success(target, remaining) = result else {
      XCTFail("\(result)")
      return
    }

    XCTAssertEqual(target,
      .ifStatement(
        .ifStatement(.other, .other),
        .skip))

    XCTAssertEqual(remaining, [])
  }
}
