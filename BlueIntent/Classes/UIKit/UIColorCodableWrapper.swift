//
//  UIColorCodableWrapper.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2023/4/6.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

/// UIColorCodableWrapper 是一个使用 @propertyWrapper 属性包装器实现的 Codable 包装器，用于将 UIColor 对象进行编码和解码
/// UIColorCodableWrapper is a Codable wrapper that uses @propertyWrapper to encode and decode UIColor objects.
@propertyWrapper
public struct UIColorCodableWrapper<T>: Codable {
  private let color: T?

  public var wrappedValue: T? {
    return color
  }

  public init(wrappedValue: T?) {
    self.color = wrappedValue
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode((color as? UIColor)?.bi.hexString)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let hexString = try container.decode(String.self)
    self.color = UIColor.bi.hex(hexString) as? T
  }
}

extension KeyedDecodingContainer {
  public func decode<T>(_ type: UIColorCodableWrapper<T>.Type, forKey key: Self.Key) throws -> UIColorCodableWrapper<T> where T: Decodable {
    return try decodeIfPresent(type, forKey: key) ?? UIColorCodableWrapper(wrappedValue: nil)
  }
}
