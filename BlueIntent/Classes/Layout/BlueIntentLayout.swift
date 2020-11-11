//
//  BlueIntentLayout.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import PureLayout

public extension CGFloat {
  static let none: CGFloat = CGFloat.greatestFiniteMagnitude
}

public extension BlueIntentExtension where Base: UIView {
  enum Edge {
    case left
    case right
    case top
    case bottom
    
    fileprivate var value: ALEdge {
      switch self {
      case .left:
        return .leading
      case .right:
        return .trailing
      case .top:
        return .top
      case .bottom:
        return .bottom
      }
    }
  }
  
  enum Dimension {
    case width
    case height
    
    fileprivate var value: ALDimension {
      switch self {
      case .width:
        return .width
      case .height:
        return .height
      }
    }
  }
  
  enum Axis {
    case vertical
    case horizontal
    case baseline
    case lastBaseline
    case firstBaseline
    
    fileprivate var value: ALAxis {
      switch self {
      case .vertical:
        return .vertical
      case .horizontal:
        return .horizontal
      case .baseline:
        return .baseline
      case .lastBaseline:
        return .lastBaseline
      case .firstBaseline:
        return .firstBaseline
      }
    }
  }
}

public extension BlueIntentExtension where Base: UIView {
  @discardableResult
  func pinEdgeToSuperview(_ edge: UIEdgeInsets = .zero) -> Self {
    let view = base.superview!
    pinEdge(.top, toEdge: .top, of: view, offset: edge.top)
    pinEdge(.left, toEdge: .left, of: view, offset: edge.left)
    pinEdge(.bottom, toEdge: .bottom, of: view, offset: edge.bottom)
    pinEdge(.right, toEdge: .right, of: view, offset: edge.right)
    return self
  }
  
  @discardableResult
  func pinEdge(_ edge: Edge,
               toEdge: Edge,
               of view: UIView,
               offset: CGFloat = 0) -> Self {
    pinEdge(edge,
            toEdge: toEdge,
            of: view,
            offset: offset,
            realation: .equal)
    return self
  }
  
  @discardableResult
  func pinEdge(_ edge: Edge,
               toEdge: Edge,
               of view: UIView,
               offset: CGFloat,
               realation: NSLayoutConstraint.Relation) -> Self {
    if offset == .none {
      return self
    }
    pinEdgeLayout(edge,
                  toEdge: toEdge,
                  of: view,
                  offset: offset,
                  realation: realation)
    return self
  }
}

public extension BlueIntentExtension where Base: UIView {
  @discardableResult
  func size(_ size: CGSize) -> Self {
    sizeLayout(size)
    return self
  }
  
  @discardableResult
  func size(width: CGFloat, height: CGFloat) -> Self {
    sizeLayout(width: width, height: height)
    return self
  }
  
  @discardableResult
  func left(_ left: CGFloat = 0) -> Self {
    leftLayout(left)
    return self
  }
  
  @discardableResult
  func right(_ right: CGFloat = 0) -> Self {
    rightLayout(right)
    return self
  }
  
  @discardableResult
  func top(_ top: CGFloat = 0) -> Self {
    topLayout(top)
    return self
  }
  
  @discardableResult
  func top(_ controller: UIViewController,
           inset: CGFloat = 0,
           relation: NSLayoutConstraint.Relation = .equal) -> Self {
    topLayout(controller, inset: inset, relation: relation)
    return self
  }
  
  @discardableResult
  func bottom(_ bottom: CGFloat = 0) -> Self {
    bottomLayout(bottom)
    return self
  }
  
  @discardableResult
  func bottom(_ controller: UIViewController,
              inset: CGFloat = 0,
              relation: NSLayoutConstraint.Relation = .equal) -> Self {
    bottomLayout(controller, inset: inset, relation: relation)
    return self
  }
  
  @discardableResult
  func width(_ width: CGFloat) -> Self {
    widthLayout(width)
    return self
  }
  
  @discardableResult
  func height(_ height: CGFloat) -> Self {
    heightLayout(height)
    return self
  }
  
  @discardableResult
  func center(_ axis: ALAxis,
              offset: CGFloat) -> Self {
    centerLayout(axis, offset: offset)
    return self
  }
  
  @discardableResult
  func center(_ axis: ALAxis,
              view: UIView,
              offset: CGFloat) -> Self {
    centerLayout(axis, view: view, offset: offset)
    return self
  }
  
  @discardableResult
  func centerInSuperview() -> Self {
    centerInSuperviewLayout()
    return self
  }
  
  @discardableResult
  func match(_ dimension: Dimension,
             to: Dimension,
             view: UIView,
             offset: CGFloat = 0) -> Self {
    matchLayout(dimension, to: to, view: view, offset: offset)
    return self
  }
  
  @discardableResult
  func match(_ dimension: Dimension,
             to: Dimension,
             view: UIView,
             multiplier: CGFloat) -> Self {
    matchLayout(dimension, to: to, view: view, multiplier: multiplier)
    return self
  }
  
  @discardableResult
  func align(_ axis: Axis,
             multiplier: CGFloat = 1) -> Self {
    alignLayout(axis, multiplier: multiplier)
    return self
  }
  
  @discardableResult
  func align(_ axis: Axis,
             offset: CGFloat = 0) -> Self {
    alignLayout(axis, offset: offset)
    return self
  }
  
  @discardableResult
  func align(_ axis: Axis,
             of: UIView,
             multiplier: CGFloat) -> Self {
    alignLayout(axis, of: of, multiplier: multiplier)
    return self
  }
  
  @discardableResult
  func align(_ axis: Axis,
             of: UIView,
             offset: CGFloat = 0) -> Self {
    alignLayout(axis, of: of, offset: offset)
    return self
  }
}

public extension BlueIntentExtension where Base: UIView {
  @discardableResult
  func sizeLayout(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
    return sizeLayout(CGSize(width: width, height: height))
  }
  
  @discardableResult
  func sizeLayout(_ size: CGSize) -> [NSLayoutConstraint] {
    return base.autoSetDimensions(to: size)
  }
  
  @discardableResult
  func pinEdgeLayout(_ edge: Edge,
                     toEdge: Edge,
                     of view: UIView,
                     offset: CGFloat,
                     realation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return base.autoPinEdge(edge.value,
                            to: toEdge.value,
                            of: view,
                            withOffset: offset,
                            relation: realation)
  }
  
  @discardableResult
  func leftLayout(_ left: CGFloat = 0) -> NSLayoutConstraint {
    return base.autoPinEdge(toSuperviewEdge: .leading, withInset: left)
  }
  
  @discardableResult
  func rightLayout(_ right: CGFloat = 0) -> NSLayoutConstraint {
    return base.autoPinEdge(toSuperviewEdge: .trailing, withInset: right)
  }
  
  @discardableResult
  func topLayout(_ top: CGFloat = 0) -> NSLayoutConstraint {
    return base.autoPinEdge(toSuperviewEdge: .top, withInset: top)
  }
  
  @discardableResult
  func topLayout(_ controller: UIViewController,
                 inset: CGFloat = 0,
                 relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return base.autoPin(toTopLayoutGuideOf: controller,
                        withInset: inset,
                        relation: relation)
  }
  
  @discardableResult
  func bottomLayout(_ bottom: CGFloat) -> NSLayoutConstraint {
    return base.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottom)
  }
  
  @discardableResult
  func bottomLayout(_ controller: UIViewController,
                    inset: CGFloat = 0,
                    relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return base.autoPin(toBottomLayoutGuideOf: controller,
                        withInset: inset,
                        relation: relation)
  }
  
  @discardableResult
  func widthLayout(_ width: CGFloat) -> NSLayoutConstraint {
    return base.autoSetDimension(.width, toSize: width)
  }
  
  @discardableResult
  func heightLayout(_ height: CGFloat) -> NSLayoutConstraint {
    return base.autoSetDimension(.height, toSize: height)
  }
  
  @discardableResult
  func centerLayout(_ axis: ALAxis,
                    offset: CGFloat) -> NSLayoutConstraint {
    return centerLayout(axis,
                        view: base.superview!,
                        offset: offset)
  }
  
  @discardableResult
  func centerLayout(_ axis: ALAxis,
                    view: UIView,
                    offset: CGFloat) -> NSLayoutConstraint {
    return base.autoAlignAxis(axis,
                              toSameAxisOf: view,
                              withOffset: offset)
  }
  
  @discardableResult
  func centerInSuperviewLayout() -> [NSLayoutConstraint] {
    return base.autoCenterInSuperview()
  }
  
  @discardableResult
  func matchLayout(_ dimension: Dimension,
                   to: Dimension,
                   view: UIView,
                   offset: CGFloat = 0) -> NSLayoutConstraint {
    return base.autoMatch(dimension.value,
                          to: to.value,
                          of: view, withOffset: offset)
  }
  
  @discardableResult
  func matchLayout(_ dimension: Dimension,
                   to: Dimension,
                   view: UIView,
                   multiplier: CGFloat) -> NSLayoutConstraint {
    return base.autoMatch(dimension.value,
                          to: to.value,
                          of: view,
                          withMultiplier: multiplier)
  }
  
  @discardableResult
  func alignLayout(_ axis: Axis,
                   multiplier: CGFloat = 1) -> NSLayoutConstraint {
    return alignLayout(axis,
                       of: base.superview!,
                       multiplier: multiplier)
  }
  
  @discardableResult
  func alignLayout(_ axis: Axis,
                   offset: CGFloat = 0) -> NSLayoutConstraint {
    return alignLayout(axis,
                       of: base.superview!,
                       offset: offset)
  }
  
  @discardableResult
  func alignLayout(_ axis: Axis,
                   of: UIView,
                   multiplier: CGFloat) -> NSLayoutConstraint {
    return base.autoAlignAxis(axis.value,
                              toSameAxisOf: of,
                              withMultiplier: multiplier)
  }
  
  @discardableResult
  func alignLayout(_ axis: Axis,
                   of: UIView,
                   offset: CGFloat = 0) -> NSLayoutConstraint {
    return base.autoAlignAxis(axis.value,
                              toSameAxisOf: of,
                              withOffset: offset)
  }
}
