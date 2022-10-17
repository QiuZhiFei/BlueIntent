//
//  UIImage+BlueIntent.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2022/9/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//
import Foundation
import UIKit

extension BlueIntentExtension where Base: UIImage {
  /**
   * 获取主色
   * @param imageData  图片数据
   * @param pixelLimit 计算的最大像素点, 值越小误差越大. 等于0时, 为图片自身的像素点. 默认值为 100 * 100
   */
  static public func getDominantColor(imageData: Data?, pixelLimit: UInt = 10000) -> UIColor? {
    guard let imageData = imageData else { return nil }
    guard let image = UIImage(data: imageData) else { return nil }
    return image.bi.getDominantColor(pixelLimit: pixelLimit)
  }

  /**
   * 获取主色
   * @param pixelLimit 计算的最大像素点, 值越小误差越大. 等于0时, 为图片自身的像素点. 默认值为 100 * 100
   */
  public func getDominantColor(pixelLimit: UInt = 10000) -> UIColor? {
    guard let cgImage = base.cgImage else { return nil }
    guard base.size.width >= 1, base.size.height >= 1 else { return nil }
    // 压缩图片, 加快计算速度, 值越小误差越大
    let (width, height): (Int, Int) = {
      if pixelLimit <= 0 {
        return (Int(base.size.width), Int(base.size.height))
      }
      if base.size.width * base.size.height > CGFloat(pixelLimit) {
        let ratio = CGFloat(sqrtf(Float(CGFloat(pixelLimit) / (base.size.width * base.size.height))))
        return (Int(ratio * base.size.width), Int(ratio * base.size.height))
      }
      return (Int(base.size.width), Int(base.size.height))
    }()
    guard width > 0, height > 0 else { return nil }

    // 取每个点的像素值
    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,      // bits per component
                                  bytesPerRow: width * 4,  // bytes per row
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let data = context.data else { return nil }
    let imageColors = NSCountedSet(capacity: width * height)
    for x in 0 ..< width {
      for y in 0 ..< height {
        let  offset = 4 * x * y
        let red = data.load(fromByteOffset: offset, as: UInt8.self)
        let green = data.load(fromByteOffset: offset + 1, as: UInt8.self)
        let blue = data.load(fromByteOffset: offset + 2, as: UInt8.self)
        let alpha = data.load(fromByteOffset: offset + 3, as: UInt8.self)
        let array = [red, green, blue, alpha]
        imageColors.add(array)
      }
    }
    guard imageColors.count > 0 else { return nil }

    // 遍历出出现次数最多的颜色
    let enumerator = imageColors.objectEnumerator()
    var maxColor: [Int] = []
    var maxCount = 0
    while let curColor = enumerator.nextObject() as? [Int], !curColor.isEmpty {
      let tmpCount = imageColors.count(for: curColor)
      if tmpCount < maxCount { continue }
      maxCount = tmpCount
      maxColor = curColor
    }
    if maxColor.count == 4 {
      return UIColor(red: CGFloat(maxColor[0]) / 255.0,
                     green: CGFloat(maxColor[1]) / 255.0,
                     blue: CGFloat(maxColor[2]) / 255.0,
                     alpha: CGFloat(maxColor[3]) / 255.0)
    }
    return nil
  }

  public func getDominantColor1(pixelLimit: UInt = 10000) -> UIColor? {
    guard let cgImage = base.cgImage else { return nil }
    guard base.size.width >= 1, base.size.height >= 1 else { return nil }
    // 压缩图片, 加快计算速度, 值越小误差越大
    let (width, height): (Int, Int) = {
      if pixelLimit <= 0 {
        return (Int(base.size.width), Int(base.size.height))
      }
      if base.size.width * base.size.height > CGFloat(pixelLimit) {
        let ratio = CGFloat(sqrtf(Float(CGFloat(pixelLimit) / (base.size.width * base.size.height))))
        return (Int(ratio * base.size.width), Int(ratio * base.size.height))
      }
      return (Int(base.size.width), Int(base.size.height))
    }()
    guard width > 0, height > 0 else { return nil }

    // 取每个点的像素值
    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,      // bits per component
                                  bytesPerRow: width * 4,  // bytes per row
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let data = context.data else { return nil }
    let imageColors = NSCountedSet(capacity: width * height)
    for x in 0 ..< width {
      for y in 0 ..< height {
        let  offset = context.bytesPerRow * y + 4 * x
        let red = data.load(fromByteOffset: offset, as: UInt8.self)
        let green = data.load(fromByteOffset: offset + 1, as: UInt8.self)
        let blue = data.load(fromByteOffset: offset + 2, as: UInt8.self)
        let alpha = data.load(fromByteOffset: offset + 3, as: UInt8.self)
        imageColors.add("\(red),\(green),\(blue),\(alpha)")
      }
    }
    guard imageColors.count > 0 else { return nil }

    // 遍历出出现次数最多的颜色
    let enumerator = imageColors.objectEnumerator()
    var maxColor: String = ""
    var maxCount = 0
    while let curColor = enumerator.nextObject() as? String, !curColor.isEmpty {
      let tmpCount = imageColors.count(for: curColor)
      if tmpCount < maxCount { continue }
      maxCount = tmpCount
      maxColor = curColor
    }
    if maxColor.count > 0 {
      let colors: [Int] = maxColor.split(separator: ",").map{ Int($0) ?? 0 }
      if colors.count == 4 {
        return UIColor(red: CGFloat(colors[0]) / 255.0,
                       green: CGFloat(colors[1]) / 255.0,
                       blue: CGFloat(colors[2]) / 255.0,
                       alpha: CGFloat(colors[3]) / 255.0)
      }
    }

    return nil
  }

  private class ColorCounter: CustomStringConvertible {
    let color: UIColor
    let count: Int
    var combiningCount: Int
    var combiningColors: [UIColor] = []

    init(color: UIColor, count: Int) {
      self.color = color
      self.count = count
      self.combiningCount = count
    }

    var description: String {
      return "color: \(color.bi.rgba), count: \(count), combiningCount: \(combiningCount) \n"
    }
  }

  public func getDominantColor2(pixelLimit: UInt = 10000) -> [UIColor]? {
    guard let cgImage = base.cgImage else { return nil }
    guard base.size.width >= 1, base.size.height >= 1 else { return nil }

    // 压缩图片, 加快计算速度, 值越小误差越大
    let (width, height): (Int, Int) = {
      if pixelLimit <= 0 {
        return (Int(base.size.width), Int(base.size.height))
      }
      if base.size.width * base.size.height > CGFloat(pixelLimit) {
        let ratio = CGFloat(sqrtf(Float(CGFloat(pixelLimit) / (base.size.width * base.size.height))))
        return (Int(ratio * base.size.width), Int(ratio * base.size.height))
      }
      return (Int(base.size.width), Int(base.size.height))
    }()
    guard width > 0, height > 0 else { return nil }

    // 取每个点的像素值
    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,      // bits per component
                                  bytesPerRow: width * 4,  // bytes per row
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let data = context.data else { return nil }
    let imageColors = NSCountedSet(capacity: width * height)
    for x in 0 ..< width {
      for y in 0 ..< height {
        let  offset = context.bytesPerRow * y + 4 * x
        let red = data.load(fromByteOffset: offset, as: UInt8.self)
        let green = data.load(fromByteOffset: offset + 1, as: UInt8.self)
        let blue = data.load(fromByteOffset: offset + 2, as: UInt8.self)
        let alpha = data.load(fromByteOffset: offset + 3, as: UInt8.self)

        let color = UIColor(red: CGFloat(red) / 255.0,
                            green: CGFloat(green) / 255.0,
                            blue: CGFloat(blue) / 255.0,
                            alpha: CGFloat(alpha) / 255.0)
        imageColors.add(color)
      }
    }

    guard imageColors.count > 0 else { return nil }

    // 排序, 获取出现次数最多的50个颜色
    var imageColorCounters = Array(imageColors.compactMap { (color) -> ColorCounter? in
      guard let rgba = color as? UIColor else { return nil }
      let count = imageColors.count(for: rgba)
      return ColorCounter(color: rgba, count: count)
    }.sorted { (lhs, rhs) -> Bool in
      return lhs.count > rhs.count
    }.prefix(50))

    // 合并颜色
    for (index, counter) in imageColorCounters.enumerated() {
      if index == imageColorCounters.count - 1 {
        break
      }
      let rightStartIdnex = index + 1
      for rightIndex in rightStartIdnex..<imageColorCounters.count {
        let rightCounter = imageColorCounters[rightIndex]
        let score = counter.color.bi.compare(color: rightCounter.color, using: .CIEDE2000)
        if score <= 10 {
          let leftCount = counter.count
          let rightCount = rightCounter.count
          counter.combiningCount += rightCount
          counter.combiningColors.append(rightCounter.color)
          rightCounter.combiningCount += leftCount
          rightCounter.combiningColors.append(counter.color)
        }
      }
    }
    
    // 合并颜色后, 重新排序
    imageColorCounters = imageColorCounters.sorted { (lhs, rhs) -> Bool in
      return lhs.combiningCount > rhs.combiningCount
    }

    // 去除相似颜色
    var result: [ColorCounter] = []
    for counter in imageColorCounters {
      if !(result.last?.combiningColors.contains(counter.color) ?? false) {
        result.append(counter)
      }
    }
    guard result.count > 0 else { return nil }
    return result.map({ $0.color })

//    imageColorCounters = imageColorCounters.filter({ counter in
//      guard let lastCounter = imageColorCounters.last else { return false }
//      debugPrint(lastCounter)
//      return !lastCounter.combiningColors.contains(counter.color)
//    })


    return nil
//    return Array(imageColorCounters.prefix(8))
//    debugPrint(imageColorCounters.prefix(8))
    //    debugPrint(Array(imageColorCounters[0..<10]))
    //    debugPrint(imageColorCounters)


    //    let enumerator = imageColors.objectEnumerator()
    //    var maxColor: String = ""
    //    var maxCount = 0
    //    while let curColor = enumerator.nextObject() as? String, !curColor.isEmpty {
    //      let tmpCount = imageColors.count(for: curColor)
    //      if tmpCount < maxCount { continue }
    //      maxCount = tmpCount
    //      maxColor = curColor
    //    }
    //    if maxColor.count > 0 {
    //      let colors: [Int] = maxColor.split(separator: ",").map{ Int($0) ?? 0 }
    //      if colors.count == 4 {
    //        return UIColor(red: CGFloat(colors[0]) / 255.0,
    //                       green: CGFloat(colors[1]) / 255.0,
    //                       blue: CGFloat(colors[2]) / 255.0,
    //                       alpha: CGFloat(colors[3]) / 255.0)
    //      }
    //    }

    return nil
  }
}










extension UIColor {

    public enum ColorDifferenceResult: Comparable {

        /// There is no difference between the two colors.
        case indentical(CGFloat)

        /// The difference between the two colors is not perceptible by human eye.
        case similar(CGFloat)

        /// The difference between the two colors is perceptible through close observation.
        case close(CGFloat)

        /// The difference between the two colors is perceptible at a glance.
        case near(CGFloat)

        /// The two colors are different, but not opposite.
        case different(CGFloat)

        /// The two colors are more opposite than similar.
        case far(CGFloat)

        init(value: CGFloat) {
            if value == 0 {
                self = .indentical(value)
            } else if value <= 1.0 {
                self = .similar(value)
            } else if value <= 2.0 {
                self = .close(value)
            } else if value <= 10.0 {
                self = .near(value)
            } else if value <= 50.0 {
                self = .different(value)
            } else {
                self = .far(value)
            }
        }

        public var associatedValue: CGFloat {
            switch self {
            case .indentical(let value),
                 .similar(let value),
                 .close(let value),
                 .near(let value),
                 .different(let value),
                 .far(let value):
                 return value
            }
        }

        public static func < (lhs: UIColor.ColorDifferenceResult, rhs: UIColor.ColorDifferenceResult) -> Bool {
            return lhs.associatedValue < rhs.associatedValue
        }

    }

    /// The different algorithms for comparing colors.
    /// @see https://en.wikipedia.org/wiki/Color_difference
    public enum DeltaEFormula {
        /// The euclidean algorithm is the simplest and fastest one, but will yield results that are unexpected to the human eye. Especially in the green range.
        /// It simply calculates the euclidean distance in the RGB color space.
        case euclidean

        /// The `CIE76`algorithm is fast and yields acceptable results in most scenario.
        case CIE76

        /// The `CIE94` algorithm is an improvement to the `CIE76`, especially for the saturated regions. It's marginally slower than `CIE76`.
        case CIE94

        /// The `CIEDE2000` algorithm is the most precise algorithm to compare colors.
        /// It is considerably slower than its predecessors.
        case CIEDE2000
    }

    /// Computes the difference between the passed in `UIColor` instance.
    ///
    /// - Parameters:
    ///   - color: The color to compare this instance to.
    ///   - formula: The algorithm to use to make the comparaison.
    /// - Returns: The different between the passed in `UIColor` instance and this instance.
    public func difference(from color: UIColor, using formula: DeltaEFormula = .CIE94) -> ColorDifferenceResult {
        switch formula {
        case .euclidean:
            let differenceValue = sqrt(pow(self.red255 - color.red255, 2) + pow(self.green255 - color.green255, 2) + pow(self.blue255 - color.blue255, 2))
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE76:
            let differenceValue = sqrt(pow(color.L - self.L, 2) + pow(color.a - self.a, 2) + pow(color.b - self.b, 2))
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        case .CIE94:
            let differenceValue = UIColor.deltaECIE94(lhs: self, rhs: color)
            let roundedDifferenceValue = differenceValue.rounded(.toNearestOrEven, precision: 100)
            return ColorDifferenceResult(value: roundedDifferenceValue)
        default:
            return ColorDifferenceResult(value: -1)
        }
    }

    private static func deltaECIE94(lhs: UIColor, rhs: UIColor) -> CGFloat {
        let kL: CGFloat = 1.0
        let kC: CGFloat = 1.0
        let kH: CGFloat = 1.0
        let k1: CGFloat = 0.045
        let k2: CGFloat = 0.015
        let sL: CGFloat = 1.0

        let c1 = sqrt(pow(lhs.a, 2) + pow(lhs.b, 2))
        let sC = 1 + k1 * c1
        let sH = 1 + k2 * c1

        let deltaL = lhs.L - rhs.L
        let deltaA = lhs.a - rhs.a
        let deltaB = lhs.b - rhs.b

        let c2 = sqrt(pow(rhs.a, 2) + pow(rhs.b, 2))
        let deltaCab = c1 - c2

        let deltaHab = sqrt(pow(deltaA, 2) + pow(deltaB, 2) - pow(deltaCab, 2))

        let p1 = pow(deltaL / (kL * sL), 2)
        let p2 = pow(deltaCab / (kC * sC), 2)
        let p3 = pow(deltaHab / (kH * sH), 2)

        let deltaE = sqrt(p1 + p2 + p3)

        return deltaE;
    }

}



import UIKit

struct RGB {
    let R: CGFloat
    let G: CGFloat
    let B: CGFloat
}

extension UIColor {

    // MARK: - Pulic

    /// The red (R) channel of the RGB color space as a value from 0.0 to 1.0.
    public var red: CGFloat {
        CIColor(color: self).red
    }

    /// The green (G) channel of the RGB color space as a value from 0.0 to 1.0.
    public var green: CGFloat {
        CIColor(color: self).green
    }

    /// The blue (B) channel of the RGB color space as a value from 0.0 to 1.0.
    public var blue: CGFloat {
        CIColor(color: self).blue
    }

    /// The alpha (a) channel of the RGBa color space as a value from 0.0 to 1.0.
    public var alpha: CGFloat {
        CIColor(color: self).alpha
    }

    // MARK: Internal

    var red255: CGFloat {
        self.red * 255.0
    }

    var green255: CGFloat {
        self.green * 255.0
    }

    var blue255: CGFloat {
        self.blue * 255.0
    }

    var rgb: RGB {
        return RGB(R: self.red, G: self.green, B: self.blue)
    }

}


import CoreGraphics

extension CGFloat {

    func rounded(_ rule: FloatingPointRoundingRule, precision: Int) -> CGFloat {
        return (self * CGFloat(precision)).rounded(rule) / CGFloat(precision)
    }

}


import UIKit

struct Lab {
    let L: CGFloat
    let a: CGFloat
    let b: CGFloat
}

struct LabCalculator {
    static func convert(RGB: RGB) -> Lab {
        let XYZ = XYZCalculator.convert(rgb: RGB)
        let Lab = LabCalculator.convert(XYZ: XYZ)
        return Lab
    }

    static let referenceX: CGFloat = 95.047
    static let referenceY: CGFloat = 100.0
    static let referenceZ: CGFloat = 108.883

    static func convert(XYZ: XYZ) -> Lab {
        func transform(value: CGFloat) -> CGFloat {
            if value > 0.008856 {
                return pow(value, 1 / 3)
            } else {
                return (7.787 * value) + (16 / 116)
            }
        }

        let X = transform(value: XYZ.X / referenceX)
        let Y = transform(value: XYZ.Y / referenceY)
        let Z = transform(value: XYZ.Z / referenceZ)

        let L = ((116.0 * Y) - 16.0).rounded(.toNearestOrEven, precision: 100)
        let a = (500.0 * (X - Y)).rounded(.toNearestOrEven, precision: 100)
        let b = (200.0 * (Y - Z)).rounded(.toNearestOrEven, precision: 100)

        return Lab(L: L, a: a, b: b)
    }
}

extension UIColor {

    /// The L* value of the CIELAB color space.
    /// L* represents the lightness of the color from 0 (black) to 100 (white).
    public var L: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.L
    }

    /// The a* value of the CIELAB color space.
    /// a* represents colors from green to red.
    public var a: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.a
    }

    /// The b* value of the CIELAB color space.
    /// b* represents colors from blue to yellow.
    public var b: CGFloat {
        let Lab = LabCalculator.convert(RGB: self.rgb)
        return Lab.b
    }

}


import UIKit

struct XYZ {
    let X: CGFloat
    let Y: CGFloat
    let Z: CGFloat
}

struct XYZCalculator {

    static func convert(rgb: RGB) -> XYZ {
        func transform(value: CGFloat) -> CGFloat {
            if value > 0.04045 {
                return pow((value + 0.055) / 1.055, 2.4)
            }

            return value / 12.92
        }

        let red = transform(value: rgb.R) * 100.0
        let green = transform(value: rgb.G) * 100.0
        let blue = transform(value: rgb.B) * 100.0

        let X = (red * 0.4124 + green * 0.3576 + blue * 0.1805).rounded(.toNearestOrEven, precision: 100)
        let Y = (red * 0.2126 + green * 0.7152 + blue * 0.0722).rounded(.toNearestOrEven, precision: 100)
        let Z = (red * 0.0193 + green * 0.1192 + blue * 0.9505).rounded(.toNearestOrEven, precision: 100)

        return XYZ(X: X, Y: Y, Z: Z)
    }

}

extension UIColor {

    /// The X value of the XYZ color space.
    public var X: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.X
    }

    /// The Y value of the XYZ color space.
    public var Y: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.Y
    }

    /// The Z value of the XYZ color space.
    public var Z: CGFloat {
        let XYZ = XYZCalculator.convert(rgb: self.rgb)
        return XYZ.Z
    }

}
