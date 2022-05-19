//
//  BlueIntentColor.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension BlueIntent.ColorRGBA: BlueIntentCompatible { }

public extension BlueIntent {
  struct ColorRGBA {
    public let red: Int
    public let green: Int
    public let blue: Int
    public let alpha: CGFloat
    
    public init(color: UIColor) {
      var red: CGFloat = 0
      var green: CGFloat = 0
      var blue: CGFloat = 0
      var alpha: CGFloat = 0
      let divisor = CGFloat(255)
      color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      self.init(Int((red * divisor).rounded()), Int((green * divisor).rounded()), Int((blue * divisor).rounded()), alpha)
    }
    
    ///   - r: The red channel (0 - 255).
    ///   - g: The green channel (0 - 255).
    ///   - b: The blue channel (0 - 255).
    ///   - a: The alpha (0.0 - 1.0).
    public init(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) {
      self.red = min(max(0, r), 255)
      self.green = min(max(0, g), 255)
      self.blue = min(max(0, b), 255)
      self.alpha = min(max(0, a), 1)
    }
  }
}

extension BlueIntent.ColorRGBA {
  public var color: UIColor {
    let divisor = CGFloat(255)
    return UIColor(red: CGFloat(red) / divisor, green: CGFloat(green) / divisor, blue: CGFloat(blue) / divisor, alpha: alpha)
  }
}

extension BlueIntent.ColorRGBA {
  public var hsl: BlueIntent.ColorHSL {
    let r = CGFloat(red) / 255
    let g = CGFloat(green) / 255
    let b = CGFloat(blue) / 255
    let max: CGFloat = Swift.max(r, g, b)
    let min: CGFloat = Swift.min(r, g, b)
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var lightness: CGFloat = (max + min) / 2
    if min != max {
      if lightness < 0.5 {
        saturation = (max - min) / (max + min)
      } else {
        saturation = (max - min) / (2 - max - min)
      }
    }
    if max == r {
      hue = (g - b) / (max - min)
    } else if max == g {
      hue = ((b - r) / (max - min)) + 2
    } else {
      hue = ((r - g) / (max - min)) + 4
    }
    hue *= 60
    if hue < 0 { hue += 360 }
    if hue.isNaN { hue = 0 }
    if saturation.isNaN { saturation = 0 }
    if lightness.isNaN { lightness = 0 }
    return BlueIntent.ColorHSL(Int(hue.rounded()), saturation, lightness, alpha)
  }
}

extension BlueIntent.ColorRGBA: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue && lhs.alpha == rhs.alpha
  }
}

extension BlueIntent.ColorHSL: BlueIntentCompatible { }

public extension BlueIntent {
  // 参照 https://docs.python.org/zh-cn/3/library/colorsys.html
  // 参照 https://github.com/Zhendryk/Colorspaces
  
  struct ColorHSL {
    public let hue: Int
    public let saturation: CGFloat
    public let lightness: CGFloat
    public var alpha: CGFloat = 1
    
    ///   - h: The hue (0 - 360).
    ///   - s: The saturation (0.0 - 1.0).
    ///   - l: The lightness (0.0 - 1.0).
    ///   - a: The alpha (0.0 - 1.0).
    public init(_ h: Int, _ s: CGFloat, _ l: CGFloat, _ a: CGFloat = 1) {
      self.hue = min(max(0, h), 360)
      self.saturation = min(max(0, (s * 100).rounded() / 100), 1)
      self.lightness = min(max(0, (l * 100).rounded() / 100), 1)
      self.alpha = min(max(0, a), 1)
    }
  }
}

public extension BlueIntent.ColorHSL {
  var color: UIColor {
    return rgba.color
  }
  
  var rgba: BlueIntent.ColorRGBA {
    var hCalc = CGFloat(hue)
    if saturation == 0.0 {
      let grayValue = Int(lightness * 255)
      return BlueIntent.ColorRGBA(grayValue, grayValue, grayValue)
    }
    var tmp1: CGFloat
    if lightness < 0.5 {
      tmp1 = lightness * (1 + saturation)
    } else {
      tmp1 = lightness + saturation - lightness * saturation
    }
    let tmp2: CGFloat = (2.0 * lightness) - tmp1
    hCalc /= 360
    var tmpR: CGFloat = hCalc + (1.0/3.0)
    if tmpR < 0 { tmpR += 1 }
    else if tmpR > 1 { tmpR -= 1 }
    
    var tmpG: CGFloat = hCalc
    if tmpG < 0 { tmpG += 1 }
    else if tmpG > 1 { tmpG -= 1 }
    
    var tmpB: CGFloat = hCalc - (1.0/3.0)
    if tmpB < 0 { tmpB += 1 }
    else if tmpB > 1 { tmpB -= 1 }
    return BlueIntent.ColorRGBA(alignColorChannel(tmpR, tmp1, tmp2), alignColorChannel(tmpG, tmp1, tmp2), alignColorChannel(tmpB, tmp1, tmp2), alpha)
  }
  
  fileprivate func alignColorChannel(_ channel: CGFloat, _ tmp1: CGFloat, _ tmp2: CGFloat) -> Int {
    var color: CGFloat = 0
    if (channel * 6) < 1 {
      color = (tmp2 + (tmp1 - tmp2) * 6 * channel)
    } else {
      if (channel * 2) < 1 {
        color = tmp1
      } else {
        if (channel * 3) < 2 {
          color = (tmp2 + (tmp1 - tmp2) * (0.666 - channel) * 6)
        } else {
          color = tmp2
        }
      }
    }
    return Int(round(color * 255))
  }
}

extension BlueIntent.ColorHSL: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hue == rhs.hue && lhs.saturation == rhs.saturation && lhs.lightness == rhs.lightness && lhs.alpha == rhs.alpha
  }
}

public extension BlueIntentExtension where Base: UIColor {
  var rgba: BlueIntent.ColorRGBA {
    return BlueIntent.ColorRGBA(color: base)
  }
  
  var hsl: BlueIntent.ColorHSL {
    return self.rgba.hsl
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

