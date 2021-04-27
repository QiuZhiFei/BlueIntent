//
//  BlueIntentBezierPath.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2021/4/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CGContext

extension CGContext: BlueIntentCompatible { }

public extension BlueIntentExtension where Base: CGContext {
  // 添加色块
  static func add(rect: CGRect,
                  color: UIColor?,
                  cornerRadius: CGFloat = 0) {
    guard let color = color else { return }
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    color.setFill()
    path.fill()
  }
  
  // 添加渐变色块
  func add(rect: CGRect,
           gradientColorStart: UIColor?,
           gradientColorEnd: UIColor?,
           locations: [CGFloat] = [0, 1],
           anchorPointStart: CGPoint = CGPoint(x: 0, y: 0.5),
           anchorPointEnd: CGPoint = CGPoint(x: 1, y: 0.5)) {
    guard let gradientColorStart = gradientColorStart,
          let gradientColorEnd = gradientColorEnd else { return }
    let context = self.base
    let colors = [gradientColorStart.cgColor, gradientColorEnd.cgColor]
    guard let color = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: locations) else { return }
    let path = UIBezierPath(rect: rect)
    context.saveGState()
    path.addClip()
    context.drawLinearGradient(color,
                               start: CGPoint(x: anchorPointStart.x * rect.width, y: anchorPointStart.x * rect.height),
                               end: CGPoint(x: anchorPointEnd.x * rect.width, y: anchorPointEnd.x * rect.height),
                               options: [])
    context.restoreGState()
  }
  
  // 添加图片
  func add(rect: CGRect,
           image: UIImage?,
           cornerRadius: CGFloat = 0) {
    guard let image = image,
          let cgImage = image.cgImage else { return }
    let context = self.base
    let imageSize = rect.size
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    context.saveGState()
    path.addClip()
    context.translateBy(x: rect.origin.x, y: rect.origin.y)
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: -imageSize.height)
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    context.restoreGState()
  }
  
  // 添加阴影
  func add(shadow: NSShadow? = nil,
           content: ((_ context: CGContext) -> Void)?) {
    let context = self.base
    guard let shadow = shadow else {
      content?(context)
      return
    }
    
    context.saveGState()
    context.setShadow(offset: shadow.shadowOffset,
                      blur: shadow.shadowBlurRadius,
                      color: (shadow.shadowColor as? UIColor)?.cgColor)
    context.beginTransparencyLayer(auxiliaryInfo: nil)
    content?(context)
    context.endTransparencyLayer()
    context.restoreGState()
  }
}

// MARK: - image

public extension BlueIntentExtension where Base: CGContext {
  static func screenshot(size: CGSize,
                         scale: CGFloat,
                         content: (() -> Void)?) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    content?()
    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return finalImage
  }
  
  static func generate(color: UIColor?,
                       size: CGSize = CGSize(width: 1, height: 1),
                       scale: CGFloat = 0) -> UIImage? {
    let image = CGContext.bi.screenshot(size: size, scale: scale) {
      CGContext.bi.add(rect: CGRect(origin: .zero, size: size), color: color)
    }
    return image
  }
  
  static func generate(image: UIImage?, color: UIColor?) -> UIImage? {
    guard let image = image else { return nil }
    guard let cgImage = image.cgImage else { return nil }
    guard let color = color else { return image }
    
    //    // 测试无效
    //    if #available(iOS 13.0, *) {
    //      return image.withTintColor(color)
    //    }
    
    let result = screenshot(size: image.size,
                            scale: image.scale) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
      context.translateBy(x: 0, y: image.size.height)
      context.scaleBy(x: 1, y: -1)
      context.setBlendMode(.normal)
      let rect = CGRect(origin: .zero, size: image.size)
      context.clip(to: rect, mask: cgImage)
      color.setFill()
      context.fill(rect)
    }
    return result
  }
}

extension BlueIntent {
  public struct BezierPath { }
}
