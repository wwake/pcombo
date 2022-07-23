//
//  File.swift
//  
//
//  Created by Bill Wake on 7/15/22.
//

import Foundation
import XCTest
@testable import pcombo

func checkSuccess<T: Equatable>(
  _ actual: ParseResult<Int, T>,
  _ expectedTarget: T,
  _ expectedRemaining: ArraySlice<Int>)
{
  guard case let .success(target, remaining) = actual else {
    XCTFail("Result was \(actual)")
    return
  }
  XCTAssertEqual(target, expectedTarget, "target")
  XCTAssertEqual(remaining, expectedRemaining, "remaining")
}

func checkFailure<T: Equatable>(_ actual: ParseResult<Int, T>, _ expected: ParseResult<Int, T>) {
  if case let .failure(location1, message1) = actual {
    if case let .failure(location2, message2) = expected {
      XCTAssertEqual(location1, location2)
      XCTAssertEqual(message1, message2)
      return
    }
  }

  XCTFail("Expected \(expected) but got \(actual)")
}
