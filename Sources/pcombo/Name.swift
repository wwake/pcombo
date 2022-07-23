//
//  Name.swift
//  
//
//  Created by Bill Wake on 7/21/22.
//


public class Name<P : Parser>  : Parser {

  public typealias Input = P.Input

  public typealias Target = P.Target

  let parser: P
  let name: String

  public init(_ parser: P, _ name: String) {
    self.parser = parser
    self.name = name
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    let result = parser.parse(input)
    switch result {
    case .success:
      return result

    case .failure(let location, let message):
      return location > input.startIndex
      ? .failure(location, message)
      : .failure(input.startIndex, name)
    }
  }
}

infix operator <%> : AdditionPrecedence

public func <%> <P: Parser>(parser: P, name: String) -> Name<P> {
  return Name(parser, name)
}
