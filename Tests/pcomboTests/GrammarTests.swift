@testable import pcombo
import XCTest

indirect enum Statement: Equatable {
  case skip
  case print
  case ifGoto(String)
  case ifStatement(Statement, Statement)
  case block([Statement])
  case line(String, Statement)
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

  func makeBlock(_ statements: [Statement]) -> Statement {
    if statements.count == 1 {
      return statements[0]
    } else {
      return Statement.block(statements)
    }
  }

  func basicLineParser() -> Bind<String, Statement> {
    let statement = Bind<String, Statement>()

    let lineNumber = match("100")

    let print = match("print") |> { _ in Statement.print }

    let ifGoto = match("if") &> lineNumber
                    |> { Statement.ifGoto($0)}

    let ifStatements = match("if") &> (statement <&& match(":"))
                    |> { Statement.ifStatement(.block($0), .skip)}

    let statementParser = print <|> ifGoto <|> ifStatements

    statement.bind(statementParser.parse)

    let statementBlock = statement <&& match(":") |> makeBlock

    let lineParser = (lineNumber <&> statementBlock)
      |> { (lineNumber, statements) in Statement.line(lineNumber, statements)}

    return Bind(lineParser.parse)
  }

  func testBasicMultipleStatementAmbiguity() {
    let parser = basicLineParser()

    // 100 IF A THEN PRINT 1: PRINT 2
    let input = ["100", "if", "print", ":", "print"]

    let result = parser.parse(input[...])

    guard case let .success(target, remaining) = result else {
      XCTFail("\(result)")
      return
    }

    XCTAssertEqual(
      target,
     .line("100",
      .ifStatement(
        .block([.print, .print]),
        .skip))
    )

    XCTAssertEqual(remaining, [])
  }

  func testBasicNestedIfStatementAmbiguity() {
    let parser = basicLineParser()

    // 100 IF A THEN PRINT 1: IF B THEN PRINT 2: PRINT 3
    let input = ["100", "if", "print", ":",
                 "if", "print", ":", "print"]

    let result = parser.parse(input[...])

    guard case let .success(target, remaining) = result else {
      XCTFail("\(result)")
      return
    }

    XCTAssertEqual(
      target,
      .line("100",
            .ifStatement(
              .block([
                .print,
                .ifStatement(.block([.print, .print]), .skip)]),
              .skip))
    )

    XCTAssertEqual(remaining, [])
  }
}
