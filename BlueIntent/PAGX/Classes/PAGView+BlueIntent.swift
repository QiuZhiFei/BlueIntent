//
//  PAGView+BlueIntent.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2022/7/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import libpag
import SDWebImage

public extension BlueIntentExtension where Base: PAGView {
  // 播放远程动画
  func play(url: String?,
            completion: ((_ pagView: PAGView) -> Void)? = nil) {
    set(url: url) { pagView, error, path in
      if path != nil {
        pagView.play()
        completion?(pagView)
      }
    }
  }

  // 播放远程动画
  func play(url: URL?,
            completion: ((_ pagView: PAGView) -> Void)? = nil) {
    set(url: url) { pagView, error, path in
      if path != nil {
        pagView.play()
        completion?(pagView)
      }
    }
  }

  // 播放本地动画
  func play(path: String?,
            completion: ((_ pagView: PAGView) -> Void)? = nil) {
    set(path: path) { pagView, error, path in
      if path != nil {
        pagView.play()
        completion?(pagView)
      }
    }
  }
}

public extension BlueIntentExtension where Base: PAGView {
  // 加载远程动画
  func set(url: String?,
           completion: ((_ pagView: PAGView, _ error: Error?, _ path: String?) -> Void)? = nil) {
    guard let url = url else {
      completion?(base, nil, nil)
      return
    }
    set(url: URL(string: url), completion: completion)
  }

  // 加载远程动画
  func set(url: URL?,
           completion: ((_ pagView: PAGView, _ error: Error?, _ path: String?) -> Void)? = nil) {
    base.bi_set(url: url, completion: completion)
  }

  // 加载本地动画
  func set(path: String?,
           completion: ((_ pagView: PAGView, _ error: Error?, _ path: String?) -> Void)? = nil) {
    base.setPath(path)
    completion?(base, nil, path)
  }
}

private extension PAGView {
  func bi_set(url: URL?,
              completion: ((_ pagView: PAGView, _ error: Error?, _ path: String?) -> Void)?) {
    let _ = PAGX.PAGCoder.addPAGCoder
    sd_internalSetImage(with: url,
                        placeholderImage: nil,
                        options: [.avoidDecodeImage, .avoidAutoSetImage, .waitStoreCache],
                        context: nil,
                        setImageBlock: nil,
                        progress: nil) { [weak self] image, _, error, _, _, imageURL in
      guard let sself = self else { return }
      let key = SDWebImageManager.shared.cacheKey(for: imageURL)
      let path = SDImageCache.shared.cachePath(forKey: key)
      sself.bi.set(path: path, completion: completion)
    }
  }
}

private var pagViewRepeats = 0

public extension BlueIntentExtension where Base: PAGView {
  // 是否播放
  var isPlaying: Bool {
    return base.isPlaying()
  }

  // 是否循环, 默认 false, 不循环
  var repeats: Bool {
    set {
      objc_setAssociatedObject(base, &pagViewRepeats, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      if newValue {
        set(repeatCount: 0)
      } else {
        set(repeatCount: 1)
      }
    }
    get {
      return (objc_getAssociatedObject(base, &pagViewRepeats) as? Bool) ?? false
    }
  }

  // 进度
  var progress: CGFloat {
    set {
      base.setProgress(CGFloat(newValue))
    }
    get {
      if self.isPlaying {
        return base.getProgress()
      }
      return 0
    }
  }

  // 开始播放
  func play() {
    base.play()
  }

  // 暂停播放
  func stop() {
    base.stop()
  }
}

public extension BlueIntentExtension where Base: PAGView {
  // sdk 版本
  static var version: String {
    return PAG.sdkVersion()
  }

  // 动画帧率
  var frameRate: CGFloat? {
    if let pagLayer = self.pagFile?.getLayerAt(0) {
      return CGFloat(pagLayer.frameRate())
    }
    return nil
  }

  // 动画时长
  var duration: Int {
    return Int(base.duration())
  }

  // 动画宽
  var width: CGFloat? {
    if let width = self.pagFile?.width() {
      return CGFloat(width)
    }
    return 0
  }

  // 动画高
  var height: CGFloat? {
    if let height = self.pagFile?.height() {
      return CGFloat(height)
    }
    return 0
  }
}

extension BlueIntentExtension where Base: PAGView {
  private var pagFile: PAGFile? {
    return base.getComposition() as? PAGFile
  }

  private func set(repeatCount: Int) {
    base.setRepeatCount(Int32(repeatCount))
  }
}
