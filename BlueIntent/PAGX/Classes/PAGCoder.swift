//
//  PAGCoder.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2022/7/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import SDWebImage

extension PAGX {
  class PAGCoder: NSObject {
    static var addPAGCoder: (() -> Void) = {
      SDImageCodersManager.shared.addCoder(PAGCoder())
      return {}
    }()
  }
}

extension PAGX.PAGCoder: SDImageCoder {
  func canDecode(from data: Data?) -> Bool {
    guard let data = data else {
      return false
    }
    let format = NSData.sd_imageFormat(forImageData: data)
    if format == .undefined {
      return true

    }
    return false
  }

  func decodedImage(with data: Data?, options: [SDImageCoderOption : Any]? = nil) -> UIImage? {
    return Self.generate(.clear, size: CGSize(width: 1, height: 1))
  }

  func canEncode(to format: SDImageFormat) -> Bool {
    return false
  }

  func encodedData(with image: UIImage?, format: SDImageFormat, options: [SDImageCoderOption : Any]? = nil) -> Data? {
    return nil
  }
}

extension PAGX.PAGCoder {
  private static func generate(_ color: UIColor, size: CGSize) -> UIImage? {
    guard size.width > 0, size.height > 0 else { return nil }
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
    guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}
