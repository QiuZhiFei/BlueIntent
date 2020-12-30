//
//  UIView+BlueIntent.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/12/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public extension BlueIntentExtension where Base: CALayer {
  // https://stackoverflow.com/questions/34269399/how-to-control-shadow-spread-and-blur
  func applySketchShadow(
    color: UIColor,
    alpha: Float = 1,
    x: CGFloat,
    y: CGFloat,
    blur: CGFloat = 0,
    spread: CGFloat = 0) {
    base.shadowColor = color.cgColor
    base.shadowOpacity = alpha
    base.shadowOffset = CGSize(width: x, height: y)
    base.shadowRadius = blur / 2.0
    if spread == 0 {
      base.shadowPath = nil
    } else {
      let dx = -spread
      let rect = base.bounds.insetBy(dx: dx, dy: dx)
      base.shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}

public extension BlueIntentExtension where Base: UIView {
  var safeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return base.safeAreaInsets
    }
    return .zero
  }
}

#endif
