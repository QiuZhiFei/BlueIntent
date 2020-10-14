//
//  BlueIntentCompatible.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public protocol BlueIntentCompatible {
  associatedtype BlueIntentCompatibleType
 
  var bi: BlueIntentCompatibleType { get }
  
  static var bi: BlueIntentCompatibleType.Type { get }
}

public extension BlueIntentCompatible {
  var bi: BlueIntentExtension<Self> {
    return BlueIntentExtension(self)
  }
  
  static var bi: BlueIntentExtension<Self>.Type {
      return BlueIntentExtension<Self>.self
  }
}

public class BlueIntentExtension<Base> {
  public let base: Base

  init(_ base: Base) {
    self.base = base
  }
}

extension NSObject: BlueIntentCompatible { }
