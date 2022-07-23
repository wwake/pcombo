//
//  Parser.swift
//
//
//  Created by Bill Wake on 7/15/22.
//

public enum ParseResult<Input, Target> {
  case success(Target, ArraySlice<Input>)
  case failure(Int, String)
}

public protocol Parser {
  associatedtype Input
  associatedtype Target
  func parse(_: ArraySlice<Input>) -> ParseResult<Input, Target>
}
