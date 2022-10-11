//
//  ViewController.swift
//  BlueIntent
//
//  Created by qiuzhifei on 10/08/2020.
//  Copyright (c) 2020 qiuzhifei. All rights reserved.
//

import UIKit
import BlueIntent

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    let whiteImage = CGContext.bi.generate(color: .white)!
    let whiteImage = UIImage(named: "1")!
//    let startTime = CFAbsoluteTimeGetCurrent()
//    
//    let linkTime = CFAbsoluteTimeGetCurrent() - startTime
//    debugPrint("zhifei log 压缩 耗时间 \(linkTime * 1000)")
//  
    
    getTime(string: "0") {
      debugPrint(whiteImage.bi.getDominantColor()?.bi.hexString)
    }
    
    getTime(string: "1") {
      debugPrint(whiteImage.bi.getDominantColor1()?.bi.hexString)
    }
  }
  
}

func getTime(string: String, method: (() -> ())?) {
  let startTime = CFAbsoluteTimeGetCurrent()
  method?()
  let linkTime = (CFAbsoluteTimeGetCurrent() - startTime)
  debugPrint("zhifei log \(string) 耗时间 \(linkTime * 1000)")
}
