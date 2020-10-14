//
//  BlueIntentAESTests.swift
//  BlueIntent_Tests
//
//  Created by zhifei qiu on 2020/10/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import BlueIntent

class BlueIntentAESTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testAES128() throws {
    let key = String.bi.random(128/8)
    let iv = String.bi.random(16)
    let text = "qiuzhifei"
    do {
      let cryptoText = try BlueIntent.AES.crypto(text, key: key, iv: iv)
      let decryptText = try BlueIntent.AES.decrypt(cryptoText, key: key, iv: iv)
      assert(decryptText == text)
    } catch (_) {
      assert(false, "should not be here")
    }
  }
  
  func testAES192() throws {
    let key = String.bi.random(192/8)
    let iv = String.bi.random(16)
    let text = "qiuzhifei"
    do {
      let cryptoText = try BlueIntent.AES.crypto(text, key: key, iv: iv)
      let decryptText = try BlueIntent.AES.decrypt(cryptoText, key: key, iv: iv)
      assert(decryptText == text)
    } catch (_) {
      assert(false, "should not be here")
    }
  }
  
  func testAES256() throws {
    let key = String.bi.random(256/8)
    let iv = String.bi.random(16)
    let text = "qiuzhifei"
    do {
      let cryptoText = try BlueIntent.AES.crypto(text, key: key, iv: iv)
      let decryptText = try BlueIntent.AES.decrypt(cryptoText, key: key, iv: iv)
      assert(decryptText == text)
    } catch (_) {
      assert(false, "should not be here")
    }
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
