//
//  BlueIntentColorTests.swift
//  BlueIntent_Tests
//
//  Created by zhifei qiu on 2020/12/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import BlueIntent

class BlueIntentColorTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testRGBA() throws {
    let hex: UInt = 0x646566
    
    let red: Int = 100
    let green: Int = 101
    let blue: Int = 102
    let alpha: CGFloat = 0.2
    
    let divisor = CGFloat(255)
    
    let color = UIColor(red: CGFloat(red) / divisor,
                        green: CGFloat(green) / divisor,
                        blue: CGFloat(blue) / divisor,
                        alpha: alpha)
    let rgba = color.bi.rgba
    XCTAssertTrue(rgba.red == red)
    XCTAssertTrue(rgba.green == green)
    XCTAssertTrue(rgba.blue == blue)
    XCTAssertTrue(rgba.alpha == alpha)
    
    XCTAssertTrue(UIColor.bi.hex(hex).bi.rgba == BlueIntent.ColorRGBA(red, green, blue))
    XCTAssertTrue(UIColor.bi.hex(hex, alpha: alpha).bi.rgba == BlueIntent.ColorRGBA(red, green, blue, alpha))
    XCTAssertFalse(UIColor.bi.hex(hex).bi.rgba == BlueIntent.ColorRGBA(red + 1, green, blue))
  }
  
  func testHSL() throws {
    let hex: UInt = 0x646566
    let alpha: CGFloat = 0.2
    let hsl = BlueIntent.ColorHSL(210, 0.01, 0.4, alpha)
    
    XCTAssertTrue(UIColor.bi.hex(hex, alpha: alpha).bi.hsl == hsl)
    
    XCTAssertTrue(UIColor.bi.hex(0xffffff).bi.hsl == BlueIntent.ColorHSL(0, 0, 1))
    
    let color = UIColor.bi.hex(hex, alpha: alpha).bi.var { (color) -> UIColor in
      let hsl = color.bi.hsl
      return BlueIntent.ColorHSL(hsl.hue, hsl.saturation, hsl.lightness, hsl.alpha).color
    }
    
    XCTAssertTrue(color.bi.hsl == UIColor.bi.hex(hex, alpha: alpha).bi.hsl)
  }
  
  func testHSLPerformance() throws {
    self.measure {
      UIColor.bi.hex(0xffffff, alpha: 1).bi.var { (color) -> UIColor in
        let hsl = color.bi.hsl
        return BlueIntent.ColorHSL(hsl.hue, hsl.saturation, hsl.lightness, hsl.alpha).color
      }
    }
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
