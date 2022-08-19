//
//  OrElse.swift
//  
//
//  Created by Bill Wake on 7/20/22.
//

import Foundation

public class OrElseWithBacktracking<P1: Parser, P2: Parser> : Parser
where P1.Input == P2.Input, P1.Target == P2.Target {

  public typealias Target = P1.Target

  let parser1 : P1
  let parser2 : P2

  public init(_ parser1: P1, _ parser2: P2) {
    self.parser1 = parser1
    self.parser2 = parser2
  }

  public func parse(_ input: ArraySlice<P1.Input>) -> ParseResult<P1.Input, Target> {
    let result1 = parser1.parse(input)

    if case .success = result1 {
      return result1
    }

    let result2 = parser2.parse(input)
    if case .success = result2 {
      return result2
    }

    return bestFailure(result1, result2)
  }

  public func bestFailure(
    _ failure1: ParseResult<P1.Input, Target>,
    _ failure2: ParseResult<P1.Input, Target>)
        -> ParseResult<P1.Input, Target> {
    guard case .failure(let location1, _) = failure1 else {
      return failure2
    }
    guard case .failure(let location2, _) = failure2 else {
      return failure1
    }

    return location1 > location2 ? failure1 : failure2
  }
}

infix operator <|> : AdditionPrecedence

public func <|> <P1: Parser, P2: Parser>(p1: P1, p2: P2) -> OrElseWithBacktracking<P1, P2> {
  return OrElseWithBacktracking(p1, p2)
}
