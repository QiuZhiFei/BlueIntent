//
//  UIColorCodableWrapperTests.swift
//  BlueIntent_Tests
//
//  Created by zhifei qiu on 2023/4/6.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import BlueIntent

class UIColorCodableWrapperTests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCodableColorDecoding() throws {
    let jsonString = "{\"color\":\"#00FF00\"}"
    let jsonData = jsonString.data(using: .utf8)!

    let decoder = JSONDecoder()
    let song = try decoder.decode(Song.self, from: jsonData)

    XCTAssertEqual(song.color, UIColor.bi.hex("#00FF00"))
    XCTAssertNotEqual(song.color, UIColor.white)
  }
}

extension UIColorCodableWrapperTests {
  struct Song: Codable {
    @UIColorCodableWrapper
    var color: UIColor?
  }
}
