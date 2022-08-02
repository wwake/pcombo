//
//  File.swift
//  
//
//  Created by Bill Wake on 8/1/22.
//

import Foundation

public class Bind<In, T> : Parser {

  public typealias Input = In

  public typealias Target = T

  public typealias ParserFunction = (ArraySlice<Input>) -> ParseResult<Input, Target>

  var parserFunction: ParserFunction? = nil

  public init() {}

  public init(_ parserFunction: @escaping ParserFunction) {
    self.parserFunction = parserFunction
  }

  public func bind(_ parserFunction: @escaping ParserFunction) {
    self.parserFunction = parserFunction
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    precondition(parserFunction != nil, "Must call bind() before parse()")

    return parserFunction!(input)
  }
}
