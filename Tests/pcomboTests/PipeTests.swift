//
//  PipeTests.swift
//  
//
//  Created by Bill Wake on 7/22/22.
//

@testable import pcombo
import XCTest

final class PipeTests: XCTestCase {
  func testPipeOperatorConvertIntToCharacter() {
    let sat1 = satisfy<Int> { _ in true }
    let pipe = sat1 |> { Array("ABCDE")[$0] }

    let result = pipe.parse([1, 0, 3])

    result.checkSuccess("B", [0,3])
  }

  func testPipeOnFailedParserReturnsFailure() {
    let sat1 = satisfy<Int>("the message") { _ in false }
    let pipe = sat1 |> { Array("ABCDE")[$0] }

    let result = pipe.parse([1, 0, 3])

    result.checkFailure(.failure(0, "the message"))
  }
}
