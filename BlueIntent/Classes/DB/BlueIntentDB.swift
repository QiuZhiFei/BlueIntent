//
//  BlueIntentDB.swift
//  BlueIntent_Example
//
//  Created by zhifei qiu on 2020/12/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FMDB

extension BlueIntent.DB {
  struct Constant {
    static let tableName = "store"
    static let fieldKey = "key"
    static let fieldValue = "value"
  }
}

public extension BlueIntent.DB {
  enum DBError: Error {
    case createDBFailed
  }
  
  enum DBResult {
    case success
    case failure(DBError)
  }
}

public extension BlueIntent {
  final class DB: NSObject {
    private let dbQueue: FMDatabaseQueue?
    public let path: String
    
    // path is Documents/blueintent/db/shared.db
    // isExcludedFromBackup is true, excluded from backups
    public static let shared: BlueIntent.DB = {
      let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let dbPath = documentDir.appendingPathComponent("blueintent/db/shared.db")
      let db = BlueIntent.DB(url: dbPath, isExcludedFromBackup: true)
      return db
    }()
    
    @discardableResult
    public convenience init(url: URL, isExcludedFromBackup: Bool = true, defer: ((DBResult) -> Void)? = nil) {
      self.init(path: url.path, isExcludedFromBackup: isExcludedFromBackup, defer: `defer`)
    }
    
    @discardableResult
    public required init(path: String, isExcludedFromBackup: Bool = true, defer: ((DBResult) -> Void)? = nil) {
      self.path = path
      
      var url = URL(fileURLWithPath: path)
      url.deleteLastPathComponent()
      if !FileManager.default.fileExists(atPath: url.path) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      }
      
      self.dbQueue = FMDatabaseQueue(path: path)
      super.init()
      dbQueue.let { (it) in
        it.inDatabase { (db) in
          #if DEBUG
          db.logsErrors = true
          db.crashOnErrors = true
          #endif
          db.executeStatements("CREATE TABLE IF NOT EXISTS \(Constant.tableName)(\(Constant.fieldKey) TEXT,\(Constant.fieldValue) BLOB,PRIMARY KEY(key))")
        }
      }
      
      dbQueue.let { (_) in
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = isExcludedFromBackup
        
        var url = URL(fileURLWithPath: self.path)
        try? url.setResourceValues(resourceValues)
      }
      
      `defer`?(dbQueue == nil ? .failure(.createDBFailed) : .success)
    }
    
    deinit {
      dbQueue?.close()
    }
  }
}

extension BlueIntent.DB {
  public subscript(key: String?) -> NSCoding? {
    set {
      set(key, value: newValue)
    }
    get {
      get(key)
    }
  }
  
  public subscript<T>(key: String?, type: T.Type) -> T? {
    set {
      self[key] = newValue as? NSCoding
    }
    get {
      return self[key] as? T
    }
  }
  
  public var count: UInt64? {
    guard let dbQueue = dbQueue else { return nil }
    var count: UInt64?
    dbQueue.inDatabase { (db) in
      if let result = db.executeQuery("SELECT COUNT(DISTINCT \(Constant.fieldKey)) FROM \(Constant.tableName)", withArgumentsIn: []) {
        if result.next() {
          count = result.unsignedLongLongInt(forColumnIndex: 0)
        }
        result.close()
      }
    }
    return count
  }
  
  public func deleteAll() {
    guard let dbQueue = dbQueue else { return }
    dbQueue.inDatabase { (db) in
      db.executeUpdate("DELETE FROM \(Constant.tableName)", withArgumentsIn: [])
    }
  }
}

fileprivate extension BlueIntent.DB {
  func set(_ key: String?, value: NSCoding?) {
    guard let key = key else { return }
    if let value = value {
      update(key, value: NSKeyedArchiver.archivedData(withRootObject: value))
      return
    }
    delete(key)
  }
  
  func update(_ key: String?, value: Data) {
    guard let key = key else { return }
    guard let dbQueue = dbQueue else { return }
    dbQueue.inDatabase { (db) in
      db.executeUpdate("INSERT OR REPLACE INTO \(Constant.tableName) (\(Constant.fieldKey), \(Constant.fieldValue)) VALUES (?, ?)", withArgumentsIn: [key, value])
    }
  }
  
  func get(_ key: String?) -> NSCoding? {
    guard let key = key else { return nil }
    guard let dbQueue = dbQueue else { return nil }
    var value: NSCoding?
    dbQueue.inDatabase { [weak self] (db) in
      guard let `self` = self else { return }
      value = self.get(key, db: db)
    }
    return value
  }
  
  func delete(_ key: String?) {
    guard let key = key else { return }
    guard let dbQueue = dbQueue else { return }
    dbQueue.inDatabase { (db) in
      db.executeUpdate("DELETE FROM \(Constant.tableName) WHERE \(Constant.fieldKey) = ?", withArgumentsIn: [key])
    }
  }
}

fileprivate extension BlueIntent.DB {
  func get(_ key: String?, db: FMDatabase?) -> NSCoding? {
    guard let key = key else { return nil }
    guard let db = db else { return nil }
    if let result = db.executeQuery("SELECT \(Constant.fieldValue) FROM \(Constant.tableName) WHERE \(Constant.fieldKey) = ?", withArgumentsIn: [key]) {
      let data = result.next() ? result.data(forColumnIndex: 0) : nil
      result.close()
      if let data = data {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
      }
    }
    return nil
  }
}

// MARK: DBWrapper

extension BlueIntent.DB.DBWrapper {
  public typealias Key = (() -> String)
}

extension BlueIntent.DB {
  
  @propertyWrapper
  public struct DBWrapper<Value> {
    private let key: Key
    private let `default`: Value
    private let db: BlueIntent.DB
    
    public init(_ key: String, default: Value, db: BlueIntent.DB) {
      self.key = {key}
      self.default = `default`
      self.db = db
    }
    
    public init(_ key: @escaping Key, default: Value, db: BlueIntent.DB) {
      self.key = key
      self.default = `default`
      self.db = db
    }
    
    public var wrappedValue: Value {
      get {
        return db[key(), Value.self] ?? self.default
      }
      set {
        db[key(), Value.self] = newValue
      }
    }
  }
}

public extension BlueIntent.DB.DBWrapper where Value: ExpressibleByNilLiteral {
  init(_ key: String, db: BlueIntent.DB) {
    self.init(key, default: nil, db: db)
  }
  
  init(_ key: @escaping Key, db: BlueIntent.DB) {
    self.init(key, default: nil, db: db)
  }
}
