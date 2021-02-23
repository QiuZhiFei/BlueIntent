# BlueIntent

[![CI Status](https://img.shields.io/travis/qiuzhifei/BlueIntent.svg?style=flat)](https://travis-ci.org/qiuzhifei/BlueIntent)
[![Version](https://img.shields.io/cocoapods/v/BlueIntent.svg?style=flat)](https://cocoapods.org/pods/BlueIntent)
[![License](https://img.shields.io/cocoapods/l/BlueIntent.svg?style=flat)](https://cocoapods.org/pods/BlueIntent)
[![Platform](https://img.shields.io/cocoapods/p/BlueIntent.svg?style=flat)](https://cocoapods.org/pods/BlueIntent)

## Example

### DB 存储
封装 [FMDB](https://github.com/ccgus/fmdb) 作为 KV 存储

#### 使用
cocoapods
```
pod 'BlueIntent/DB'
```
#### shared db
路径 Documents/blueintent/db/shared.db, 不同步 iCloud
```
let db = BlueIntent.DB.shared

db["key", String.self] = "value"
let value = BlueIntent.DB.shared["key", String.self]
```
#### 自定义 db
```
let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let dbPath = documentDir.appendingPathComponent("blueintent/db/shared.db")
let db = BlueIntent.DB(url: dbPath, isExcludedFromBackup: true)

db["key", String.self] = "value"
let value = BlueIntent.DB.shared["key", String.self]
```

#### 使用属性装饰器
```
# 自定义 DB Class
struct CustomDB {
    @BlueIntent.DB.DBWrapper("name", default: "name", db: .custom)
    static var name
    
    @BlueIntent.DB.DBWrapper("age", db: .custom)
    static var age: Int?
    
    @BlueIntent.DB.DBWrapper({"uid" + "\(Date().timeIntervalSince1970)"}, db: .custom)
    static var uid: String?
}

CustomDB.name = "name1"
```

## Requirements

## Installation

BlueIntent is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BlueIntent'
```

## Author

qiuzhifei, qiuzhifei521@gmail.com

## License

BlueIntent is available under the MIT license. See the LICENSE file for more info.
