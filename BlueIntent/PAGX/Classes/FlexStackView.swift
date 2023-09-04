//
//  FlexStackView.swift
//  s27
//
//  Created by zhifei qiu on 2023/9/3.
//

import Foundation
import UIKit

extension FlexStackView {
  /// 每个 item 的布局。
  public struct ItemBox {
    let frame: CGRect
    
    init(frame: CGRect) {
      self.frame = frame
    }
  }
  
  /// 每行的布局
  public struct LineBox {
    /// 第几行
    let index: Int
    
    /// 行的 frame
    let frame: CGRect
    
    /// 行内所有 itemBox
    let itemBoxes: [ItemBox]
  }
  
  /// 所有内容的布局
  public struct ContentBox {
    /// 每个 view 的布局
    let viewFrames: [CGRect]
    
    /// 每行的布局
    let lineBoxes: [LineBox]
    
    /// 内容的 size
    let size: CGSize
  }
}

/// Flex 布局协议
public protocol FlexStackViewLayout {
  /// 渲染并得到最终的 box
  func render(maxWidth: CGFloat,
              maxHeight: CGFloat,
              arrangedSubviews: [UIView]) -> FlexStackView.ContentBox
}

/// Flex 布局，规则同 Web CSS flex。
public final class FlexStackView: UIView {
  public let layout: FlexStackViewLayout

  private let contentView = UIView()
  public private(set) var arrangedSubviews: [UIView] = []
  
  public required init(layout: FlexStackViewLayout = RowLayout()) {
    self.layout = layout
    super.init(frame: .zero)
    directionalLayoutMargins = .zero
    self.addSubview(contentView)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    let maxWidth = bounds.size.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing
    let box = layout.render(maxWidth: maxWidth, maxHeight: CGFloat.greatestFiniteMagnitude, arrangedSubviews: arrangedSubviews)
    
    let contentViewFrame = CGRect(x: directionalLayoutMargins.leading,
                                  y: directionalLayoutMargins.top,
                                  width: max(0, bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing),
                                  height: max(0, bounds.height - directionalLayoutMargins.top - directionalLayoutMargins.bottom))
    if contentView.frame != contentViewFrame {
      contentView.frame = contentViewFrame
    }
    
    for (index, frame) in box.viewFrames.enumerated() {
      let view = arrangedSubviews[index]
      if view.frame != frame {
        view.frame = frame
      }
    }
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    let maxWidth = size.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing
    let maxHeight = CGFloat.greatestFiniteMagnitude
    let box = layout.render(maxWidth: maxWidth, maxHeight: CGFloat.greatestFiniteMagnitude, arrangedSubviews: arrangedSubviews)
    
    /// 无内容
    if box.lineBoxes.count == 0 {
      return .zero
    }
    /// 有内容
    return CGSize(width: box.size.width + directionalLayoutMargins.leading + directionalLayoutMargins.trailing,
                  height: box.size.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom)
  }
}

/// Public Methods
extension FlexStackView {
  /// 添加子视图
  public func addArrangedSubview(_ view: UIView) {
    arrangedSubviews.append(view)
    contentView.addSubview(view)
    setNeedsLayout()
  }

  /// 删除子视图
  public func removeArrangedSubview(_ view: UIView) {
    guard let index = arrangedSubviews.firstIndex(of: view) else { return }
    arrangedSubviews.remove(at: index)
    view.removeFromSuperview()
    setNeedsLayout()
  }

  /// 删除所有子视图
  public func removeAllArrangedSubviews() {
    for view in arrangedSubviews {
      view.removeFromSuperview()
    }
    arrangedSubviews.removeAll()
  }

  /// 根据宽度返回最合适的尺寸
  public func sizeThatFits(width: CGFloat) -> CGSize {
    return sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
  }
}
