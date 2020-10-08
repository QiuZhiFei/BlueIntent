//
//  Optional+BlueIntent.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

// 作用域函数,参照 kotlin https://www.kotlincn.net/docs/reference/scope-functions.html
extension Optional {
  @discardableResult
  public func `var`<T>(_ block: ((_ it: Wrapped?) -> T?)) -> T? {
    return block(self)
  }
  
  @discardableResult
  public func `let`(_ block: ((_ it: Wrapped) -> Void)?) -> Self {
    if let block = block, let it = self {
      block(it)
    }
    return self
  }
  
  @discardableResult
  public func `let`(_ default: (() -> Wrapped), block: ((_ it: Wrapped) -> Void)?) -> Wrapped {
    let it = self ?? `default`()
    block?(it)
    return it
  }
}

