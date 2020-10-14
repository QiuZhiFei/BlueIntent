//
//  BlueIntentAES.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/14.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BlueIntent
import CryptoSwift

extension BlueIntent {
  public enum AES {
    public static func crypto(_ string: String, key: String, iv: String) throws -> String {
      assert(key.count == 16 || key.count == 24 || key.count == 32, "key count should == 16 || 24 || 32")
      assert(iv.count == 16, "iv count should == 16")
      let aes = try CryptoSwift.AES(key: key, iv: iv)
      let ciphertext = try aes.encrypt(Array(string.utf8))
      return ciphertext.toHexString()
    }
    
    public static func decrypt(_ string: String?, key: String, iv: String) throws -> String? {
      guard let string = string else { return nil }
      assert(key.count == 16 || key.count == 24 || key.count == 32, "key count should == 16 || 24 || 32")
      assert(iv.count == 16, "iv count should == 16")
      let aes = try CryptoSwift.AES(key: key, iv: iv)
      let ciphertext = try aes.decrypt(Array(hex: string))
      return String(bytes: ciphertext, encoding: .utf8)
    }
  }
}
