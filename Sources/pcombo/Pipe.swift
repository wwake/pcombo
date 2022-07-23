//
//  Pipe.swift
//  
//
//  Created by Bill Wake on 7/22/22.
//

public class Pipe<P : Parser, Value> : Parser {

  public typealias Input = P.Input
  public typealias Target = Value

  let parser: P
  let mapper: (P.Target) -> Value

  public init(_ parser: P, _ mapper: @escaping (P.Target) -> Value) {
    self.parser = parser
    self.mapper = mapper
  }

  public func parse(_ input: ArraySlice<P.Input>) -> ParseResult<P.Input, Value> {
    let result = parser.parse(input)

    switch result {
    case .failure(let location, let message):
      return .failure(location, message)

    case .success(let value, let remaining):
      return .success(mapper(value), remaining)
    }
  }
}

infix operator |> : MultiplicationPrecedence

func |> <P: Parser, V>(p: P, fn: @escaping (P.Target) -> V) -> Pipe<P, V> {
  return Pipe(p, fn)
}
