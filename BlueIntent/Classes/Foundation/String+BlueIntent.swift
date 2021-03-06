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

extension String: BlueIntentCompatible { }

extension BlueIntentExtension where Base == String {
  public static func random(_ length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-=_+[]{}\\|;:'\",<.>/?"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
}
