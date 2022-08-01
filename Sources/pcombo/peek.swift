//
//  peek.swift
//  
//
//  Created by Bill Wake on 8/1/22.
//

import Foundation

public class peek<P : Parser>  : Parser {

  public typealias Input = P.Input

  public typealias Target = Int

  let parser: P

  public init(_ parser: P) {
    self.parser = parser
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {

    let result = parser.parse(input)

    switch result {
    case .success:
      return .success(0, input)
    case .failure(let location, let message):
      return .failure(location, message)
    }
  }
}
