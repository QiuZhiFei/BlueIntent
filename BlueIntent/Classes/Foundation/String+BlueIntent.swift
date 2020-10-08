//
//  String+BlueIntent.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension String {
  public subscript(safe bounds: Range<Int>) -> String {
    return String(Array(self)[safe: bounds])
  }
  
  public subscript(safe lower: Int?, _ upper: Int?) -> String {
    return String(Array(self)[safe: lower, upper])
  }
  
  public subscript(safe bounds: NSRange) -> String {
    return String(Array(self)[safe: bounds])
  }
}
