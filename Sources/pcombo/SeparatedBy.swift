//
//  File.swift
//  
//
//  Created by Bill Wake on 8/1/22.
//

import Foundation

public class SeparatedBy<P1: Parser, P2: Parser> : Parser
where P1.Input == P2.Input {

  public typealias Input = P1.Input
  public typealias Target = (P1.Target, [(P2.Target, P1.Target)])

  let parser1 : P1
  let parser2 : P2

  public init(_ parser1: P1, _ parser2: P2) {
    self.parser1 = parser1
    self.parser2 = parser2
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {

    let parser = parser1 <&> <*>(parser2 <&> parser1)
    return parser.parse(input)
  }
}

public class SeparatedByKeepLeft<P1: Parser, P2: Parser> : Parser
where P1.Input == P2.Input {
  public typealias Input = P1.Input
  public typealias Target = [P1.Target]

  let parser1 : P1
  let parser2 : P2

  public init(_ parser1: P1, _ parser2: P2) {
    self.parser1 = parser1
    self.parser2 = parser2
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    let parser = parser1 <&> <*>(parser2 &> parser1)
    return parser.parse(input)
  }
}

precedencegroup ExponentiationPrecedence {
  higherThan: MultiplicationPrecedence
  associativity: left
}

infix operator <&&> : ExponentiationPrecedence

public func <&&> <P1: Parser, P2: Parser>(parser1: P1, parser2: P2) -> SeparatedBy<P1, P2> {
  return SeparatedBy(parser1, parser2)
}

infix operator <&& : ExponentiationPrecedence

public func <&& <P1: Parser, P2: Parser>(parser1: P1, parser2: P2) -> SeparatedByKeepLeft<P1, P2> {
  return SeparatedByKeepLeft(parser1, parser2)
}
