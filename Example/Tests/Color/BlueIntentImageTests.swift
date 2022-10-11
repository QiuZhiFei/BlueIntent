//
//  BlueIntentImageTests.swift
//  BlueIntent_Tests
//
//  Created by zhifei qiu on 2022/10/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import BlueIntent

class BlueIntentImageTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testDominantColor() throws {
    let whiteImage = CGContext.bi.generate(color: .white)!
    assert(whiteImage.bi.getDominantColor()!.bi.hexString == "#FFFFFF")

    let redImage = CGContext.bi.generate(color: UIColor.red)!
    assert(redImage.bi.getDominantColor()!.bi.hexString == "#FF0000")

    let whiteAndBlackImage: UIImage = {
      let size = CGSize(width: 10, height: 10)
      return CGContext.bi.screenshot(size: size,
                                     scale: UIScreen.main.scale) {
        let whiteImageWidth: CGFloat = 5
        CGContext.bi.add(rect: CGRect(x: 0, y: 0, width: whiteImageWidth, height: size.height), color: .white)
        CGContext.bi.add(rect: CGRect(x: whiteImageWidth, y: 0, width: size.width - whiteImageWidth, height: size.height), color: .black)
      }!
    }()
    assert(whiteAndBlackImage.bi.getDominantColor()!.bi.hexString == "#FFFFFF")
  }

}
