//
//  Check.swift
//  
//
//  Created by Bill Wake on 8/2/22.
//

import Foundation

public class Check2<P: Parser, Target2> : Parser {
  public typealias Input = P.Input
  public typealias Target = Target2

  let parser : P
  let checker: (P.Target, ArraySlice<P.Input>)
  -> ParseResult<P.Input, Target2>

  init(_ parser: P, _ checker: @escaping (P.Target, ArraySlice<P.Input>) -> ParseResult<P.Input, Target2>) {
    self.parser = parser
    self.checker = checker
  }

  public func parse(_ input: ArraySlice<P.Input>) -> ParseResult<P.Input, Target2> {
    let parse = parser.parse(input)

    switch parse {
    case .failure(let position, let message):
      return .failure(position, message)

    case .success(let target, let remaining):
      return checker(target, remaining)
    }
  }
}

infix operator |&> : MultiplicationPrecedence

public func |&> <P: Parser, Target2>(p: P, fn: @escaping (P.Target, ArraySlice<P.Input>) -> ParseResult<P.Input, Target2>) -> Check2<P, Target2> {
  return Check2(p, fn)
}

public class Check<P: Parser> : Parser {
  public typealias Input = P.Input
  public typealias Target = P.Target

  let parser : P
  let checker: (Target) -> (Int, String)?

  init(_ parser: P, _ checker: @escaping (Target) -> (Int, String)?) {
    self.parser = parser
    self.checker = checker
  }

  public func parse(_ input: ArraySlice<P.Input>) -> ParseResult<P.Input, P.Target> {
    let parse = parser.parse(input)

    switch parse {
    case .failure:
      return parse

    case .success(let target, _):
      let check = checker(target)
      if let (location, message) = check {
        return .failure(location, message)
      } else {
        return parse
      }
    }
  }
}

infix operator <&| : MultiplicationPrecedence

public func <&| <P: Parser>(p: P, fn: @escaping (P.Target) -> (Int, String)?) -> Check<P> {
  return Check(p, fn)
}
