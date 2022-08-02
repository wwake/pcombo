//
//  File.swift
//  
//
//  Created by Bill Wake on 7/15/22.
//

import Foundation
import XCTest
@testable import pcombo

extension ParseResult {
  func checkSuccess(
    _ expectedTarget: Target,
    _ expectedRemaining: ArraySlice<Input>)
  where Target: Equatable, Input: Equatable
  {
    guard case let .success(target, remaining) = self else {
      XCTFail("Result was \(self)")
      return
    }
    XCTAssertEqual(target, expectedTarget, "target")
    XCTAssertEqual(remaining, expectedRemaining, "remaining")
  }

  func checkFailure(_ expected: ParseResult<Int, Target>) where Target: Equatable {

    if case let .failure(location1, message1) = self {
      if case let .failure(location2, message2) = expected {
        XCTAssertEqual(location1, location2, "location")
        XCTAssertEqual(message1, message2, "message")
        return
      }
    }

    XCTFail("Expected \(expected) but got \(self)")
  }
}
