//
//  inject.swift
//  
//
//  Created by Bill Wake on 8/22/22.
//


public class inject<Input, InjectedValue> : Parser {
  public typealias Target = InjectedValue

  let value: InjectedValue

  public init(_ value: InjectedValue) {
    self.value = value
  }

  public func parse(_ input: ArraySlice<Input>) -> ParseResult<Input, Target> {
    return .success(value, input)
  }
}
