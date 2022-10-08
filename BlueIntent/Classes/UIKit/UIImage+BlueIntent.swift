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
}
