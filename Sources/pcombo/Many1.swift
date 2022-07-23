//
//  Many1.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//

public class Many1<P : Parser>  : Parser {

  public typealias Input = P.Input

  public typealias Target = [P.Target]

  let parser: P

  public init(_ parser: P) {
    self.parser = parser
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {

    var values = Target()
    var lastRemaining = input

    let firstResult = parser.parse(input)

    switch firstResult {
    case .success(let value, let remaining):
      values.append(value)
      lastRemaining = remaining

    case .failure(let location, let message):
      return .failure(location, message)
    }

    var result = parser.parse(lastRemaining)
    while case .success(let value, let remaining) = result {
      values.append(value)
      lastRemaining = remaining
      result = parser.parse(lastRemaining)
    }

    return .success(values, lastRemaining)
  }
}

prefix operator <+>

public prefix func <+> <P: Parser>(parser: P) -> Many1<P> {
  return Many1(parser)
}
