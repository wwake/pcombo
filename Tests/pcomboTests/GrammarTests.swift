@testable import pcombo
import XCTest

indirect enum Statement: Equatable {
  case skip
  case print
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

  func match(_ value: String) -> satisfy<String> {
    satisfy { $0 == value }
  }

  func testDanglingElse() throws {
    let statement = Bind<String, Statement>()

    let printStatement = match("print") |> { _ in Statement.print }

    let ifStatement = match("if") &> statement <&> <?>(match("else") &> statement)

    let statements = printStatement <|> (ifStatement |> buildIfStatement)

    statement.bind(statements.parse)

    //if expr1 then if expr2 then other1 else other2
    let result = statement.parse(["if", "if", "print", "else", "print"])

    guard case let .success(target, remaining) = result else {
      XCTFail("\(result)")
      return
    }

    XCTAssertEqual(target,
      .ifStatement(
        .ifStatement(.print, .print),
        .skip))

    XCTAssertEqual(remaining, [])
  }

  func testBasicMultipleStatementsPerLine() {
    let statement = Bind<String, Statement>()

    let printStatement = satisfy{$0 == "print"} |> { _ in Statement.print }

    //let ifGoto =

    let lineNumber = satisfy{$0 == "100"}
    //let lineParser =
  }
}
