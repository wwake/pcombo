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

    let statements = printStatement <||> (ifStatement |> buildIfStatement)

    statement.bind(statements.parse)

    //if expr1 then if expr2 then other1 else other2
    let result = statement.parse(["if", "if", "print", "else", "print"])

    let expectedTarget =
      Statement.ifStatement(
        .ifStatement(.print, .print),
        .skip)

    result.checkSuccess(expectedTarget, [])
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

    let ifStatements = match("if") &> statement <&& match(":")
    |> { Statement.ifStatement(.block($0), .skip)}

    let statementParser = print <||> ifGoto <||> ifStatements

    statement.bind(statementParser.parse)

    let lineParser = (lineNumber <&> (statement <&& match(":")))
    |> { (lineNumber, statements) in Statement.line(lineNumber, self.makeBlock(statements))}

    return Bind(lineParser.parse)
  }


  func testBasicMultipleStatementAmbiguity() {
    let parser = basicLineParser()

    // 100 IF A THEN PRINT 1: PRINT 2
    let input = ["100", "if", "print", ":", "print"]

    let result = parser.parse(input[...])

    let expectedTarget =
      Statement.line("100",
            .ifStatement(
              .block([.print, .print]),
              .skip))

    result.checkSuccess(expectedTarget, [])
  }

  func testBasicNestedIfStatementAmbiguity() {
    let parser = basicLineParser()

    // 100 IF A THEN PRINT 1: IF B THEN PRINT 2: PRINT 3
    let input = ["100", "if", "print", ":",
                 "if", "print", ":", "print"]

    let result = parser.parse(input[...])

    let expectedTarget =
    Statement.line("100",
                   .ifStatement(
                    .block([
                      .print,
                      .ifStatement(.block([.print, .print]), .skip)]),
                    .skip))

    result.checkSuccess(expectedTarget, [])
  }

  indirect enum Expression: Equatable {
    case number(String)
    case variable(String)
    case op2(Expression, String, Expression)
  }

  func toExpression(_ argument: (Expression, [(String, Expression)])) -> Expression {
    let (factor1, array) = argument
    var result = factor1
    array.forEach { (op, factor2) in
      result = .op2(result, op, factor2)
    }
    return result
  }

  func exprParser() -> Bind<String, Expression> {
    let number = match("42") |> { Expression.number($0) }
    let variable = match("x") |> { Expression.variable($0) }

    let expression = Bind<String, Expression>()

    let factor = number <|> variable <|> (match("(") &> expression <& match(")"))

    let term = (factor <&&> ( match("*") <|> match("/"))) |> toExpression

    let sum = (term <&&> ( match("+") <|> match("-")))
      |> toExpression

    expression.bind(sum.parse)

    return expression
  }

  // term -> factor <*>( ("*"|"/") factor)
  // factor -> number | variable | "(" expression ")

  func testExpressions() {
    let input = ["x", "*", "42", "/", "x"]
    let result = exprParser().parse(input[...])
    result.checkSuccess(
      .op2(
        .op2(.variable("x"), "*", .number("42")),
        "/",
        .variable("x")), [])
  }

  func testExpressionPrecedence() {
    let input = ["x", "+", "42", "*", "42"]
    let result = exprParser().parse(input[...])
    result.checkSuccess(
      .op2(
        .variable("x"),
        "+",
        .op2(.number("42"), "*", .number("42"))),
         [])
  }
}
