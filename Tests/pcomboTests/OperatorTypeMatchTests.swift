@testable import pcombo

import XCTest


public class AndThenTuple<P1: Parser, P2: Parser> : Parser
where P1.Input == P2.Input {
  public typealias Input = P1.Input
  public typealias Target = (P1.Target, P2.Target)

  let parser1 : P1
  let parser2 : P2

  public init(_ parser1: P1, _ parser2: P2) {
    self.parser1 = parser1
    self.parser2 = parser2
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    let result1 = parser1.parse(input)

    switch result1 {
    case .success(let target1, let remaining1):
      let result2 = parser2.parse(remaining1)

      switch result2 {
      case .success(let target2, let remaining2):
        return .success((target1, target2), remaining2)

      case .failure(let location2, let message2):
        return .failure(location2, message2)
      }

    case .failure(let location1, let message1):
      return .failure(location1, message1)
    }
  }
}

public class AndThenElementArray<P1: Parser, P2: Parser> : Parser
where P1.Input == P2.Input,
      P2.Target == [P1.Target]
{
  public typealias Input = P1.Input
  public typealias Target = P2.Target

  let parser1 : P1
  let parser2 : P2

  public init(_ parser1: P1, _ parser2: P2) {
    self.parser1 = parser1
    self.parser2 = parser2
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    let result1 = parser1.parse(input)

    switch result1 {
    case .success(let target1, let remaining1):
      let result2 = parser2.parse(remaining1)

      switch result2 {
      case .success(let target2, let remaining2):
        var result = target2
        result.insert(target1, at:0)
        return .success(result, remaining2)

      case .failure(let location2, let message2):
        return .failure(location2, message2)
      }

    case .failure(let location1, let message1):
      return .failure(location1, message1)
    }
  }
}

infix operator &&& : MultiplicationPrecedence

public func &&& <P1: Parser, P2: Parser>(parser1: P1, parser2: P2) -> AndThenTuple<P1, P2> {
  return AndThenTuple(parser1, parser2)
}

public func &&& <P1: Parser, P2: Parser>(parser1: P1, parser2: P2) -> AndThenElementArray<P1, P2> {
  return AndThenElementArray(parser1, parser2)
}

func match(_ value: String) -> satisfy<String> {
  satisfy { $0 == value }
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

//  let statementBlock = statement <&& match(":") |> makeBlock

  let lineParser =
          (lineNumber <&> (statement <&& match(":")))
  |> { (lineNum, array) in Statement.line(lineNum, .block(array)) }

//  |> { (lineNum, array) in Statement.skip }
  //|> { (lineNum, array) in Statement.line(lineNum, .block(array)) }

  let foo = Bind(lineParser.parse)
  return foo
}


final class OperatorTypeMatchTests: XCTestCase {

    func xtest_zero() throws {
        XCTFail("Tests not yet implemented in Tests")
    }
}
