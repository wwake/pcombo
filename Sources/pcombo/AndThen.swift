//
//  AndThen.swift
//  
//
//  Created by Bill Wake on 7/20/22.
//

import Foundation

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


public class AndThenArray<P: Parser> : Parser
{
  public typealias Input = P.Input
  public typealias Target = [P.Target]

  let parser1 : P
  let parser2 : P

  public init(_ parser1: P, _ parser2: P) {
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
          return .success([target1, target2], remaining2)

      case .failure(let location2, let message2):
        return .failure(location2, message2)
      }

    case .failure(let location1, let message1):
      return .failure(location1, message1)
    }
  }
}

infix operator <&> : MultiplicationPrecedence

public func <&> <P1: Parser>(parser1: P1, parser2: P1) -> AndThenArray<P1> {
  return AndThenArray(parser1, parser2)
}

public func <&> <P1: Parser, P2: Parser>(parser1: P1, parser2: P2) -> AndThenTuple<P1, P2> {
  return AndThenTuple(parser1, parser2)
}
