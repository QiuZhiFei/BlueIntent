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
    static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let testDBPath = documentDir.appendingPathComponent("blueintent/db/test.db")
    static let customDBPath = documentDir.appendingPathComponent("blueintent/db/custom.db")
  }
}

extension BlueIntent.DB {
  static let custom = BlueIntent.DB(url: BlueIntentDBTests.Constant.customDBPath, isExcludedFromBackup: true)
}

extension BlueIntentDBTests {
  struct CustomDB {
    @BlueIntent.DB.DBWrapper("name", default: "name", db: .custom)
    static var name
    
    @BlueIntent.DB.DBWrapper("age", db: .custom)
    static var age: Int?
    
    @BlueIntent.DB.DBWrapper({"uid" + "\(Date().timeIntervalSince1970)"}, db: .custom)
    static var uid: String?
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
  override class func setUp() {
    BlueIntent.DB.shared.deleteAll()
    debugPrint("shared db path: \(BlueIntent.DB.shared.path)")
    
    try? FileManager.default.removeItem(at: Constant.testDBPath)
    debugPrint("test db path: \(Constant.testDBPath)")
    
    try? FileManager.default.removeItem(at: Constant.customDBPath)
    debugPrint("custom db path: \(Constant.customDBPath)")
  }
  
  func testFailedDB() throws {
    BlueIntent.DB(path: "1.db") { (result) in
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
    let db = BlueIntent.DB(url: Constant.testDBPath) { (result) in
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
  
  func testDBWrapper() throws {
    typealias db = CustomDB
    
    // test default name
    XCTAssertTrue(db.name == "name")
    
    db.name = "name1"
    XCTAssertTrue(db.name == "name1")
    
    XCTAssertNil(db.age)
    db.age = 1
    XCTAssertTrue(db.age == 1)
    
    db.uid = "123"
    XCTAssertNil(db.uid)
  }
}
