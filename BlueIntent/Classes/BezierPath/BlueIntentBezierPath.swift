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
           contentMode: BlueIntent.BezierPath.ContentMode = .scaleToFill,
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
    
    let imageFrame = image.bi.frame(containerFrame: CGRect(origin: .zero, size: rect.size),
                                    contentMode: contentMode)
    context.draw(cgImage, in: imageFrame)
    
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

public extension BlueIntent.BezierPath {
  enum ContentMode {
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case redraw
    case center
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    case scaleAspectFitWidth
    case scaleAspectFitHeight
    
    public init(_ contentMode: UIView.ContentMode) {
      switch contentMode {
      case .scaleToFill:
        self = .scaleToFill
      case .scaleAspectFit:
        self = .scaleAspectFit
      case .scaleAspectFill:
        self = .scaleAspectFill
      case .redraw:
        self = .redraw
      case .center:
        self = .center
      case .top:
        self = .top
      case .bottom:
        self = .bottom
      case .left:
        self = .left
      case .right:
        self = .right
      case .topLeft:
        self = .topLeft
      case .topRight:
        self = .topRight
      case .bottomLeft:
        self = .bottomLeft
      case .bottomRight:
        self = .bottomRight
      @unknown default:
        fatalError()
      }
    }
  }
}

public extension BlueIntentExtension where Base: UIImage {
  func frame(containerFrame: CGRect,
             contentMode: BlueIntent.BezierPath.ContentMode) -> CGRect {
    switch contentMode {
    case .scaleToFill:
      return CGRect(origin: .zero, size: containerFrame.size)
    case .scaleAspectFit:
      let imageSize = self.base.size
      var width = containerFrame.width
      var height = width / imageSize.width * imageSize.height
      if max(imageSize.width, imageSize.height) == imageSize.height {
        height = containerFrame.height
        width = height / imageSize.height * imageSize.width
      }
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .scaleAspectFill:
      let imageSize = self.base.size
      var width = containerFrame.width
      var height = width / imageSize.width * imageSize.height
      if max(imageSize.width, imageSize.height) == imageSize.width {
        height = containerFrame.height
        width = height / imageSize.height * imageSize.width
      }
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .redraw:
      return self.frame(containerFrame: containerFrame, contentMode: .scaleToFill)
    case .center:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .top:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: containerFrame.height - height,
                    width: width,
                    height: height)
    case .bottom:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: 0,
                    width: width,
                    height: height)
    case .left:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: 0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .right:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: containerFrame.width - width,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .topLeft:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: self.frame(containerFrame: containerFrame, contentMode: .left).origin.x,
                    y: self.frame(containerFrame: containerFrame, contentMode: .top).origin.y,
                    width: width,
                    height: height)
    case .topRight:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: self.frame(containerFrame: containerFrame, contentMode: .right).origin.x,
                    y: self.frame(containerFrame: containerFrame, contentMode: .top).origin.y,
                    width: width,
                    height: height)
    case .bottomLeft:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: self.frame(containerFrame: containerFrame, contentMode: .left).origin.x,
                    y: self.frame(containerFrame: containerFrame, contentMode: .bottom).origin.y,
                    width: width,
                    height: height)
    case .bottomRight:
      let imageSize = self.base.size
      let width = imageSize.width
      let height = imageSize.height
      return CGRect(x: self.frame(containerFrame: containerFrame, contentMode: .right).origin.x,
                    y: self.frame(containerFrame: containerFrame, contentMode: .bottom).origin.y,
                    width: width,
                    height: height)
    case .scaleAspectFitWidth:
      let imageSize = self.base.size
      let width = containerFrame.width
      let height = width / imageSize.width * imageSize.height
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    case .scaleAspectFitHeight:
      let imageSize = self.base.size
      let height = containerFrame.height
      let width = height / imageSize.height * imageSize.width
      return CGRect(x: (containerFrame.width - width) / 2.0,
                    y: (containerFrame.height - height) / 2.0,
                    width: width,
                    height: height)
    }
  }
}

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
