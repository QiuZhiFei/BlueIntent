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

  var xyz: [CGFloat] {
    let rgba = self.rgba

    func XYZ_helper(c: CGFloat) -> CGFloat {
      return (0.04045 < c ? pow((c + 0.055)/1.055, 2.4) : c/12.92) * 100
    }

    let R = XYZ_helper(c: CGFloat(rgba.red) / 255)
    let G = XYZ_helper(c: CGFloat(rgba.green) / 255)
    let B = XYZ_helper(c: CGFloat(rgba.blue) / 255)

    let X: CGFloat = (R * 0.4124) + (G * 0.3576) + (B * 0.1805)
    let Y: CGFloat = (R * 0.2126) + (G * 0.7152) + (B * 0.0722)
    let Z: CGFloat = (R * 0.0193) + (G * 0.1192) + (B * 0.9505)

    return [X, Y, Z]
  }

  var lab: [CGFloat] {
    let XYZ = self.xyz

    func LAB_helper(c: CGFloat) -> CGFloat {
      return 0.008856 < c ? pow(c, 1/3) : ((7.787 * c) + (16/116))
    }

    let X: CGFloat = LAB_helper(c: XYZ[0]/95.047)
    let Y: CGFloat = LAB_helper(c: XYZ[1]/100.0)
    let Z: CGFloat = LAB_helper(c: XYZ[2]/108.883)

    let L: CGFloat = (116 * Y) - 16
    let A: CGFloat = 500 * (X - Y)
    let B: CGFloat = 200 * (Y - Z)

    return [L, A, B]
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

public extension BlueIntentExtension where Base: UIColor {
  /**
   * Get RGB hex string, like `#000000`.
   */
  var hexString: String {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    base.getRed(&r, green: &g, blue: &b, alpha: nil)
    return [r, g, b].map { String(format: "%02lX", Int($0 * 255)) }.reduce("#", +)
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

public enum DeltaEFormula {
  case CIEDE2000
}

extension BlueIntentExtension where Base: UIColor {
  public func compare(color: UIColor, using formula: DeltaEFormula = .CIEDE2000) -> CGFloat {
    switch formula {
    case .CIEDE2000:
      return compareByCIEDE2000(color: color)
    }
  }

  private func compareByCIEDE2000(color: UIColor) -> CGFloat {
    func rad2deg(r: CGFloat) -> CGFloat {
      return r * CGFloat(180/Double.pi)
    }

    func deg2rad(d: CGFloat) -> CGFloat {
      return d * CGFloat(Double.pi/180)
    }

    let k_l = CGFloat(1), k_c = CGFloat(1), k_h = CGFloat(1)

    let LAB1 = self.lab
    let L_1 = LAB1[0], a_1 = LAB1[1], b_1 = LAB1[2]

    let LAB2 = color.bi.lab
    let L_2 = LAB2[0], a_2 = LAB2[1], b_2 = LAB2[2]

    let C_1ab = sqrt(pow(a_1, 2) + pow(b_1, 2))
    let C_2ab = sqrt(pow(a_2, 2) + pow(b_2, 2))
    let C_ab  = (C_1ab + C_2ab)/2

    let G = 0.5 * (1 - sqrt(pow(C_ab, 7)/(pow(C_ab, 7) + pow(25, 7))))
    let a_1_p = (1 + G) * a_1
    let a_2_p = (1 + G) * a_2

    let C_1_p = sqrt(pow(a_1_p, 2) + pow(b_1, 2))
    let C_2_p = sqrt(pow(a_2_p, 2) + pow(b_2, 2))

    // Read note 1 (page 23) for clarification on radians to hue degrees
    let h_1_p = (b_1 == 0 && a_1_p == 0) ? 0 : (atan2(b_1, a_1_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)
    let h_2_p = (b_2 == 0 && a_2_p == 0) ? 0 : (atan2(b_2, a_2_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)

    let deltaL_p = L_2 - L_1
    let deltaC_p = C_2_p - C_1_p

    var h_p: CGFloat = 0
    if (C_1_p * C_2_p) == 0 {
      h_p = 0
    } else if abs(h_2_p - h_1_p) <= 180 {
      h_p = h_2_p - h_1_p
    } else if (h_2_p - h_1_p) > 180 {
      h_p = h_2_p - h_1_p - 360
    } else if (h_2_p - h_1_p) < -180 {
      h_p = h_2_p - h_1_p + 360
    }

    let deltaH_p = 2 * sqrt(C_1_p * C_2_p) * sin(deg2rad(d: h_p/2))

    let L_p = (L_1 + L_2)/2
    let C_p = (C_1_p + C_2_p)/2

    var h_p_bar: CGFloat = 0
    if (h_1_p * h_2_p) == 0 {
      h_p_bar = h_1_p + h_2_p
    } else if abs(h_1_p - h_2_p) <= 180 {
      h_p_bar = (h_1_p + h_2_p)/2
    } else if abs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) < 360 {
      h_p_bar = (h_1_p + h_2_p + 360)/2
    } else if abs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) >= 360 {
      h_p_bar = (h_1_p + h_2_p - 360)/2
    }

    let T1 = cos(deg2rad(d: h_p_bar - 30))
    let T2 = cos(deg2rad(d: 2 * h_p_bar))
    let T3 = cos(deg2rad(d: (3 * h_p_bar) + 6))
    let T4 = cos(deg2rad(d: (4 * h_p_bar) - 63))
    let T = 1 - rad2deg(r: 0.17 * T1) + rad2deg(r: 0.24 * T2) - rad2deg(r: 0.32 * T3) + rad2deg(r: 0.20 * T4)

    let deltaTheta = 30 * exp(-pow((h_p_bar - 275)/25, 2))
    let R_c = 2 * sqrt(pow(C_p, 7)/(pow(C_p, 7) + pow(25, 7)))
    let S_l =  1 + ((0.015 * pow(L_p - 50, 2))/sqrt(20 + pow(L_p - 50, 2)))
    let S_c = 1 + (0.045 * C_p)
    let S_h = 1 + (0.015 * C_p * T)
    let R_t = -sin(deg2rad(d: 2 * deltaTheta)) * R_c

    // Calculate total

    let P1 = deltaL_p/(k_l * S_l)
    let P2 = deltaC_p/(k_c * S_c)
    let P3 = deltaH_p/(k_h * S_h)
    let deltaE = sqrt(pow(P1, 2) + pow(P2, 2) + pow(P3, 2) + (R_t * P2 * P3))

    return deltaE
  }
}
