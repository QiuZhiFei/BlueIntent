//
//  ViewController.swift
//  BlueIntent
//
//  Created by qiuzhifei on 10/08/2020.
//  Copyright (c) 2020 qiuzhifei. All rights reserved.
//

import UIKit
import BlueIntent
import UIImageColors
import DominantColor

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

//    let image = UIImage(named: "IMG_0666")!
//
//    debugPrint(image.getColors(quality: .low)?.background.bi.rgba)
//
//    let color = image.bi.getDominantColor1(pixelLimit: 30000)
//    view.backgroundColor = color
//    debugPrint(color?.bi.rgba)


    
//    debugPrint(image.dominantColors().first?.bi.rgba)
    
//    view.backgroundColor = image.getColors()?.background
    
    
    let whiteImage = UIImage(named: "1")!
//    getTime(string: "0") {
//      debugPrint(whiteImage.bi.getDominantColor()?.bi.hexString)
//    }
//
    getTime(string: "1") {
      debugPrint(whiteImage.bi.getDominantColor1()?.bi.hexString)
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    let image = UIImage(named: "IMG_7459")!
    getTime(string: "0") {
      let color = image.bi.getDominantColor(pixelLimit: 6000)
//          debugPrint()
    }
  }
}

func getTime(string: String, method: (() -> ())?) {
  let startTime = CFAbsoluteTimeGetCurrent()
  method?()
  let linkTime = (CFAbsoluteTimeGetCurrent() - startTime)
  debugPrint("zhifei log \(string) 耗时间 \(linkTime * 1000)")
}
