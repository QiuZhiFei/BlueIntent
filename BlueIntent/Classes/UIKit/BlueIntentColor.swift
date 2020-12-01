//
//  BlueIntentColor.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public extension BlueIntent {
  struct ColorRGBA: Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(color: UIColor) {
      var red: CGFloat = 0
      var green: CGFloat = 0
      var blue: CGFloat = 0
      var alpha: CGFloat = 0
      color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      self.red = red
      self.green = green
      self.blue = blue
      self.alpha = alpha
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue && lhs.alpha == rhs.alpha
    }
  }
}

public extension BlueIntentExtension where Base: UIColor {
  var rgba: BlueIntent.ColorRGBA {
    return BlueIntent.ColorRGBA(color: base)
  }
  
  static func hex(_ hex: UInt, alpha: CGFloat = 1) -> UIColor {
    let divisor = CGFloat(255)
    let red = CGFloat((hex & 0xFF0000) >> 16) / divisor
    let green = CGFloat((hex & 0x00FF00) >>  8) / divisor
    let blue = CGFloat( hex & 0x0000FF) / divisor
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  static func hex(_ hex: String?, alpha: CGFloat = 1) -> UIColor? {
    guard let hex = hex else { return nil }
    guard hex.first == "#" else { return nil }
    if hex.count == 4 {
      let hex = "#" + Array(hex).map { (char) -> String in
        if char == "#" { return "" }
        return "\(char)\(char)"
      }.joined()
      return UIColor.bi.hex(hex)
    }
    if hex.count == 7, let hex = UInt(hex[safe: 1, 7], radix: 16) {
      return UIColor.bi.hex(hex, alpha: alpha)
    }
    return nil
  }
}

#if os(iOS)
public extension BlueIntentExtension where Base: UIColor {
  static func dynamic(_ light: UInt, dark: UInt? = nil) -> UIColor {
    let dark = dark.var { (it) -> UIColor? in
      if let it = it {
        return self.hex(it)
      }
      return nil
    }
    return self.dynamic(self.hex(light), dark: dark)
  }
  
  static func dynamic(_ light: UIColor, dark: UIColor?) -> UIColor {
    if #available(iOS 13.0, *) {
      return UIColor { (traitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
          return dark ?? light
        }
        return light
      }
    }
    return light
  }
}
#endif

