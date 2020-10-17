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
}



