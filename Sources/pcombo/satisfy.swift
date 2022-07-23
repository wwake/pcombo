//
//  satisfy.swift
//  
//
//  Created by Bill Wake on 7/15/22.
//

import Foundation

public class satisfy<InputType>: Parser  {
  public typealias Input = InputType

  public typealias Target = InputType

  let message: String
  let condition : (Input) -> Bool

  public init(_ message: String = "Did not find expected value", _ condition: @escaping (Input) -> Bool) {
    self.message = message
    self.condition = condition
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    if input.isEmpty {
      return .failure(input.startIndex, message)
    }
    if condition(input.first!) {
      return .success(input.first!, input.dropFirst())
    }
    return .failure(input.startIndex, message)
  }
}
