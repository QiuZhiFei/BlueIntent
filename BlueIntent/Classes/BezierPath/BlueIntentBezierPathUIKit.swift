//
//  BlueIntentBezierPathUIKit.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2021/5/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import YYText

// MARK: - Base

public protocol BlueIntentBezierPathViewRendering {
  var frame: CGRect { set get }
  var backgroundColor: UIColor? { set get }
}

public protocol BlueIntentBezierPathViewTransform {
  var rotateAngle: CGFloat? { set get }
  var anchorPoint: CGPoint? { set get }
}

extension BlueIntent.BezierPath.View: BlueIntentCompatible { }
extension BlueIntent.BezierPath.Label: BlueIntentCompatible { }

// MARK: - View

public extension BlueIntent.BezierPath {
  struct View: BlueIntentBezierPathViewRendering, BlueIntentBezierPathViewTransform {
    public var frame: CGRect
    public var backgroundColor: UIColor?
    
    public var rotateAngle: CGFloat?
    public var anchorPoint: CGPoint?
    
    public var contentMode: BlueIntent.BezierPath.ContentMode = .scaleToFill
    
    public var image: UIImage?
    public var cornerRadius: CGFloat?
    public var shadow: NSShadow?
    
    public init(frame: CGRect = .zero) {
      self.frame = frame
    }
  }
}

// MARK: - Label

public extension BlueIntent.BezierPath {
  enum TruncationType {
    case none
    case start
    case end
    case middle
    
    var raw: YYTextTruncationType {
      switch self {
      case .none:
        return .none
      case .start:
        return .start
      case .end:
        return .end
      case .middle:
        return .middle
      }
    }
  }
  
  struct Label: BlueIntentBezierPathViewRendering {
    public var frame: CGRect
    public var backgroundColor: UIColor?
    
    public var text: NSAttributedString?
    public var insets = UIEdgeInsets.zero

    public var maximumNumberOfRows: Int = 1
    public var truncationType: TruncationType = .end
    public var truncationToken: NSAttributedString?
    public var textBoundingRect: CGRect {
      return layout?.textBoundingRect ?? .zero
    }
    // 渲染完整的 rect
    public var fitBoundingRect: CGRect {
      var height = layout?.textBoundingRect.height ?? 0
      if height != 0 {
        height = height + insets.top + insets.bottom
      }
      let frame = CGRect(x: self.frame.origin.x,
                         y: self.frame.origin.y,
                         width: self.frame.size.width,
                         height: height)
      return frame
    }
    
    var layout: YYTextLayout? {
      guard let text = self.text else { return nil }
      guard text.length > 0 else { return nil }
      
      let container = YYTextContainer(size: frame.size, insets: insets)
      container.maximumNumberOfRows = UInt(maximumNumberOfRows)
      container.truncationType = truncationType.raw
      if let truncationToken = truncationToken {
        container.truncationToken = truncationToken
      } else {
        let attributes = text.attributes(at: 0, effectiveRange: nil)
        container.truncationToken = NSAttributedString(string: "\u{2026}", attributes: attributes)
      }
      
      let layout = YYTextLayout(container: container, text: text)
      return layout
    }
    
    public init(frame: CGRect = .zero, text: NSAttributedString? = nil) {
      self.text = text
      self.frame = frame
    }
  }
}

// MARK: - CGContext

extension BlueIntentExtension where Base: CGContext {
  public func add(_ view: BlueIntent.BezierPath.View) {
    let anchorPoint = view.anchorPoint ?? CGPoint.zero
    let rect = CGRect(x: -anchorPoint.x,
                      y: -anchorPoint.y,
                      width: view.frame.width,
                      height: view.frame.height)
    let cornerRadius = view.cornerRadius ?? 0
    
    var backgroundShadow: NSShadow? = nil
    var imageShadow: NSShadow? = nil
    if view.backgroundColor != nil {
      backgroundShadow = view.shadow
    }
    if view.image != nil {
      imageShadow = view.shadow
    }
    if view.backgroundColor != nil, view.image != nil {
      // 图片未充满，以图片为 shadow，否则以 background 为 shadow
      backgroundShadow = view.shadow
      imageShadow = nil
      if let filled = view.image?.bi.frame(containerFrame: CGRect(origin: .zero, size: rect.size), contentMode: view.contentMode).contains(CGRect(origin: .zero, size: rect.size)), filled == false {
        backgroundShadow = nil
        imageShadow = view.shadow
      }
    }
    
    self.add(shadow: backgroundShadow) { (context) in
      context.saveGState()
      context.translateBy(x: anchorPoint.x + view.frame.origin.x, y: anchorPoint.y + view.frame.origin.y)
      if let rotateAngle = view.rotateAngle {
        context.rotate(by: rotateAngle * CGFloat.pi/180)
      }
      CGContext.bi.add(rect: rect,
                       color: view.backgroundColor,
                       cornerRadius: cornerRadius)
      context.restoreGState()
    }
    
    self.add(shadow: imageShadow) { (context) in
      context.saveGState()
      context.translateBy(x: anchorPoint.x + view.frame.origin.x, y: anchorPoint.y + view.frame.origin.y)
      if let rotateAngle = view.rotateAngle {
        context.rotate(by: rotateAngle * CGFloat.pi/180)
      }
      context.bi.add(rect: rect,
                     image: view.image,
                     contentMode: view.contentMode,
                     cornerRadius: cornerRadius)
      context.restoreGState()
    }
  }
  
  public func add(_ view: BlueIntent.BezierPath.Label) {
    guard let layout = view.layout else { return }
    
    if let backgroundColor = view.backgroundColor {
      var view = BlueIntent.BezierPath.View(frame: view.fitBoundingRect)
      view.backgroundColor = backgroundColor
      self.add(view)
    }
    
    BlueIntentYYText.yyTextDraw(self.base,
                                layout: layout,
                                point: view.frame.origin,
                                size: layout.textBoundingSize,
                                cancel: nil)
  }
}
