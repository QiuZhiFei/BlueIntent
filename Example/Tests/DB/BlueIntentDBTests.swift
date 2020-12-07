//
//  BlueIntentDBTests.swift
//  BlueIntent_Tests
//
//  Created by zhifei qiu on 2020/12/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import BlueIntent

extension BlueIntentDBTests {
  struct Constant {
    static let dbName = "test.db"
    static let dbDir = NSHomeDirectory() + "/DB"
    static let dbPath =  "\(dbDir)/com/db/\(dbName)"
  }
}

extension BlueIntentDBTests {
  @objc(_TtCC16BlueIntent_Tests17BlueIntentDBTests8TestSong)@objcMembers
  final class TestSong: NSObject, NSCoding {
    struct Constant {
      static let titleKey = "title"
    }
    
    let title: String
    
    required init(title: String) {
      self.title = title
      super.init()
    }
    
    func encode(with coder: NSCoder) {
      coder.encode(self.title, forKey: Constant.titleKey)
    }
    
    convenience init?(coder: NSCoder) {
      let title = coder.decodeObject(forKey: Constant.titleKey) as! String
      self.init(title: title)
    }
  }
}

class BlueIntentDBTests: XCTestCase {
  
  override func setUpWithError() throws {
    try? FileManager.default.removeItem(atPath: Constant.dbPath)
    BlueIntent.DB.shared.deleteAll()
    
    debugPrint("DB Custom Path: \(Constant.dbPath)")
    debugPrint("DB Shared Path: \(BlueIntent.DB.shared.path)")
  }
  
  func testFailedDB() throws {
    BlueIntent.DB(path: Constant.dbName) { (result) in
      switch result {
      case .success:
        XCTAssertTrue(false)
      case .failure(_):
        XCTAssertTrue(true)
      }
    }
  }
  
  func testSharedDB() throws {
    let db = BlueIntent.DB.shared
    XCTAssertTrue(db.count == 0)
    
    db["key", String.self] = "value"
    XCTAssertTrue(db["key", String.self] == "value")
    XCTAssertTrue(db.count == 1)
  }
  
  func testCustomDB() throws {
    let db = BlueIntent.DB(path: Constant.dbPath) { (result) in
      switch result {
      case .success:
        XCTAssertTrue(true)
      case .failure(_):
        XCTAssertTrue(false)
      }
    }
    
    XCTAssertTrue(db.count == 0)
    
    db["key", String.self] = "value"
    XCTAssertTrue(db["key", String.self] == "value")
    XCTAssertTrue(db.count == 1)
    
    db["key", String.self] = nil
    XCTAssertTrue(db["key", String.self] == nil)
    XCTAssertTrue(db.count == 0)
    
    db["key", Int.self] = 1
    XCTAssertTrue(db["key", Int.self] == 1)
    XCTAssertTrue(db.count == 1)
    db.deleteAll()
    XCTAssertTrue(db.count == 0)
    
    let song = TestSong(title: "Apologize")
    db["key", TestSong.self] = song
    XCTAssertNotNil(db["key", TestSong.self])
    XCTAssertTrue(db["key", TestSong.self]?.title == song.title)
    XCTAssertTrue(db.count == 1)
  }
}
