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
  
  struct UIImageColorsCounter {
      let color: String
      let count: Int
      init(color: String, count: Int) {
          self.color = color
          self.count = count
      }
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
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
    base.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //    let path = URL(fileURLWithPath: NSHomeDirectory() + "/1.png")
    //    debugPrint(path)
    //    debugPrint(NSHomeDirectory())
    //    debugPrint(finalImage?.pngData())
    //    do {
    //      try finalImage?.pngData()?.write(to: path)
    //    } catch let error {
    //      debugPrint(error)
    //    }
    //    try? finalImage?.pngData()?.write(to: path)
#if os(OSX)
    guard let cgImage = finalImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
#else
    guard let cgImage = finalImage?.cgImage else { return nil }
#endif
    guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
      fatalError("UIImageColors.getColors failed: could not get cgImage data.")
    }
    
    //    guard let data = context.data else { return nil }
    let imageColors = NSCountedSet(capacity: width * height)
    for x in 0 ..< width {
      for y in 0 ..< height {
        //        let  offset = 4 * x * y
//        let offset = (y * cgImage.bytesPerRow) + (x * 4)
//        let blue = data[offset]
//        let green = data[offset + 1]
//        let red = data[offset + 2]
//        let alpha = data[offset + 3]
        let pixel: Int = (y * cgImage.bytesPerRow) + (x * 4)
        if 127 <= data[pixel+3] {
          imageColors.add("\((Double(data[pixel+2])*1000000)+(Double(data[pixel+1])*1000)+(Double(data[pixel])))")
        }
        //        imageColors.add("\(red),\(green),\(blue),\(alpha)")
      }
    }
    guard imageColors.count > 0 else { return nil }
    
    // 遍历出出现次数最多的颜色
    let enumerator = imageColors.objectEnumerator()
    var sortedColors = NSMutableArray(capacity: imageColors.count)
    while let K = enumerator.nextObject() as? String {
      let C = imageColors.count(for: K)
      sortedColors.add(UIImageColorsCounter(color: K, count: C))
    }
    let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
        let m = main as! UIImageColorsCounter, o = other as! UIImageColorsCounter
        if m.count < o.count {
            return .orderedDescending
        } else if m.count == o.count {
            return .orderedSame
        } else {
            return .orderedAscending
        }
    }
    sortedColors.sort(comparator: sortedColorComparator)
    
    
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
}
