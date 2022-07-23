//
//  Many.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

public class Many<P : Parser>  : Parser {

  public typealias Input = P.Input

  public typealias Target = [P.Target]

  let parser: P

  public init(_ parser: P) {
    self.parser = parser
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {

    var values = Target()
    var lastRemaining = input

    var result = parser.parse(lastRemaining)
    while case .success(let value, let remaining) = result {
      values.append(value)
      lastRemaining = remaining
      result = parser.parse(lastRemaining)
    }

    return .success(values, lastRemaining)
  }
}

prefix operator <*>

public prefix func <*> <P: Parser>(parser: P) -> Many<P> {
  return Many(parser)
}
