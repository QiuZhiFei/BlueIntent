//
//  BlueIntentApp.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension BlueIntent {
  struct App {
    static func bundleIdentifier() -> String? {
      return Bundle.main.bundleIdentifier
    }
    
    static func shortVersion() -> String? {
      return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
  }
}
