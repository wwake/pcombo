//
//  File.swift
//  
//
//  Created by Bill Wake on 8/1/22.
//

import Foundation

public class Optional<P : Parser>  : Parser {

  public typealias Input = P.Input

  public typealias Target = P.Target?

  let parser: P

  public init(_ parser: P) {
    self.parser = parser
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    let result = parser.parse(input)

    switch result {
    case .success(let target, let remaining):
      return .success(target, remaining)

    case .failure:
      return .success(nil, input)
    }
  }
}

prefix operator <?>

public prefix func <?> <P: Parser>(parser: P) -> Optional<P> {
  return Optional(parser)
}
