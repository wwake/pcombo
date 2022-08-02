//
//  Check.swift
//  
//
//  Created by Bill Wake on 8/2/22.
//

import Foundation

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

func <&| <P: Parser>(p: P, fn: @escaping (P.Target) -> (Int, String)?) -> Check<P> {
  return Check(p, fn)
}
