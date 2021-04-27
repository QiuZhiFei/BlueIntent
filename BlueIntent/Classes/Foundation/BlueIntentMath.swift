//
//  BlueIntentMath.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2021/5/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

extension Int {
  public subscript(safe lower: Int, _ upper: Int) -> Self? {
    if lower > upper { return nil }
    if self <= lower { return lower }
    if self >= upper { return upper }
    return self
  }
}
