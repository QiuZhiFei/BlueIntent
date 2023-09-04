//
//  FlexStackView+RowLayout.swift
//  s27
//
//  Created by zhifei qiu on 2023/9/3.
//

import Foundation

extension FlexStackView {
  public final class RowLayout {
    /// 行间距, default is 8。
    public let minimumLineSpacing: CGFloat

    /// 列间距, default is 8。
    public let minimumInteritemSpacing: CGFloat

    /// 行内对齐方式，default is center。
    public let alignItems: AlignItems

    /// 最大行
    public let lineLimit: Int

    /// 记录 view 自定义的列间距
    private var customInteritemSpacings: [UIView: CGFloat] = [:]

    public init(minimumLineSpacing: CGFloat = 8,
                minimumInteritemSpacing: CGFloat = 8,
                alignItems: AlignItems = .center,
                lineLint: Int = Int.max) {
      self.minimumLineSpacing = minimumLineSpacing
      self.minimumInteritemSpacing = minimumInteritemSpacing
      self.alignItems = alignItems
      self.lineLimit = lineLint
    }
  }
}

extension FlexStackView.RowLayout {
  /// 行内对齐方式。
  public enum AlignItems {
    /// 上对齐。
    ///
    ///  -----------
    /// |■ ■ ■ ■ ■ ■|
    /// |           |
    /// |           |
    ///  -----------
    case flexStart

    /// 下对齐。
    ///
    ///  -----------
    /// |           |
    /// |           |
    /// |■ ■ ■ ■ ■ ■|
    ///  -----------
    case flexEnd

    /// 居中。
    ///
    ///  -----------
    /// |           |
    /// |■ ■ ■ ■ ■ ■|
    /// |           |
    ///  -----------
    case center
  }
}

extension FlexStackView.RowLayout {
  /// spacingUseDefault
  public static let spacingUseDefault: CGFloat = CGFloat.greatestFiniteMagnitude

  /// 自定义 index 列间距
  public func setCustomInteritemSpacing(_ interitemSpacing: CGFloat, after arrangedSubview: UIView) {
    if interitemSpacing == FlexStackView.RowLayout.spacingUseDefault {
      customInteritemSpacings.removeValue(forKey: arrangedSubview)
      return
    }
    customInteritemSpacings[arrangedSubview] = interitemSpacing
  }

  /// 获取 view 的列间距
  public func customInteritemSpacing(after arrangedSubview: UIView) -> CGFloat {
    return customInteritemSpacings[arrangedSubview] ?? minimumInteritemSpacing
  }
}

extension FlexStackView.RowLayout: FlexStackViewLayout {
  /// 每个 item 的布局。
  private final class RowItemBox {
    var frame: CGRect

    let item: UIView

    init(item: UIView, frame: CGRect) {
      self.item = item
      self.frame = frame
    }

    var box: FlexStackView.ItemBox {
      return FlexStackView.ItemBox(frame: frame)
    }
  }

  /// 每行的布局
  private final class RowLineBox {
    /// 第几行
    var index: Int

    /// 行的 frame
    var frame: CGRect

    /// 行内所有 item 的 frame
    var itemBoxes: [RowItemBox]

    init(index: Int, frame: CGRect, itemBoxes: [RowItemBox]) {
      self.index = index
      self.frame = frame
      self.itemBoxes = itemBoxes
    }

    var box: FlexStackView.LineBox {
      return FlexStackView.LineBox(index: index, frame: frame, itemBoxes: itemBoxes.map { $0.box })
    }
  }

  /// 渲染并得到最终的 box
  public func render(maxWidth: CGFloat,
                     maxHeight: CGFloat,
                     arrangedSubviews: [UIView]) -> FlexStackView.ContentBox {
    let itemSizes = arrangedSubviews.map {
      $0.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
    }

    /// 每行的布局
    var rowLineBoxes: [RowLineBox] = []

    for (index, itemSize) in itemSizes.enumerated() {
      /// 要布局的 item
      let item = arrangedSubviews[index]

      /// 保证每个 item.width 不超过 maxWidth
      let itemSize = CGSize(width: min(itemSize.width, maxWidth), height: itemSize.height)

      /// 当前行剩余的空间
      let contentRemainingWidth: CGFloat = {
        if let lastItemBox = rowLineBoxes.last?.itemBoxes.last {
          return maxWidth - lastItemBox.frame.maxX - customInteritemSpacing(after: lastItemBox.item)
        }
        return maxWidth
      }()

      /// item 添加到当前的布局
      if let currentLineBox = rowLineBoxes.last, itemSize.width <= contentRemainingWidth {
        /// 当前行有足够的空间，在当前行继续
        let itemBox = RowItemBox(item: item,
                                 frame: CGRect(x: currentLineBox.itemBoxes.last!.frame.maxX + customInteritemSpacing(after: currentLineBox.itemBoxes.last!.item),
                                               y: currentLineBox.frame.origin.y,
                                               width: itemSize.width,
                                               height: itemSize.height))
        currentLineBox.itemBoxes.append(itemBox)
      } else {
        /// 新的一行
        if rowLineBoxes.count >= lineLimit {
          /// 超过可渲染的最大行数
          break
        }
        let itemBox = RowItemBox(item: item,
                                 frame: CGRect(x: 0,
                                               y: rowLineBoxes.last == nil ? 0 : rowLineBoxes.last!.frame.maxY + minimumLineSpacing,
                                               width: itemSize.width,
                                               height: itemSize.height))
        let currentLineBox = RowLineBox(index: rowLineBoxes.count, frame: .zero, itemBoxes: [itemBox])
        rowLineBoxes.append(currentLineBox)
      }

      /// 当前行添加 item 后，修正其 frame
      let currentLineBox = rowLineBoxes.last!
      currentLineBox.frame = {
        let width: CGFloat = currentLineBox.itemBoxes.last!.frame.maxX
        let height: CGFloat = currentLineBox.itemBoxes.map { $0.frame }.max(by: { $0.height < $1.height })!.height
        let originX: CGFloat = 0
        let originY: CGFloat = currentLineBox.index == 0 ? 0 : (rowLineBoxes[currentLineBox.index - 1].frame.maxY + minimumLineSpacing)
        return CGRect(x: originX, y: originY, width: width, height: height)
      }()
    }

    /// 适配 alignItems
    switch alignItems {
    case .flexStart:
      for lineBox in rowLineBoxes {
        for itemBox in lineBox.itemBoxes {
          itemBox.frame.origin.y = lineBox.frame.origin.y
        }
      }
    case .flexEnd:
      for lineBox in rowLineBoxes {
        for itemBox in lineBox.itemBoxes {
          itemBox.frame.origin.y = lineBox.frame.origin.y + lineBox.frame.height - itemBox.frame.height
        }
      }
    case .center:
      for lineBox in rowLineBoxes {
        for itemBox in lineBox.itemBoxes {
          itemBox.frame.origin.y = lineBox.frame.origin.y + (lineBox.frame.height - itemBox.frame.height) / 2.0
        }
      }
    }

    /// 所有 view 的 frame。
    let viewFrames = rowLineBoxes.flatMap({ $0.itemBoxes }).compactMap({ $0.frame })

    /// 内容高度 = 最后一行最高内容的 maxY
    let height = (rowLineBoxes.last?.frame.maxY ?? 0).rounded(.up)
    /// 内容宽度 = 可展示的最大宽度
    let width = (rowLineBoxes.map { $0.frame }.max(by: { $0.width < $1.width })?.width ?? 0).rounded(.up)

    return FlexStackView.ContentBox(viewFrames: viewFrames,
                                    lineBoxes: rowLineBoxes.map { $0.box },
                                    size: CGSize(width: width, height: height))
  }
}
