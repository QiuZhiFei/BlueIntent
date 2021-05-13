//
//  ViewController.swift
//  BlueIntent_BezierPath_Example
//
//  Created by zhifei qiu on 2021/5/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import BlueIntent

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let imageView = UIImageView(frame: view.bounds)
    view.addSubview(imageView)
    imageView.image = CGContext.bi.screenshot(size: imageView.bounds.size,
                                              scale: UIScreen.main.scale) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
      let bounds = imageView.bounds
      
      // backgound
      var bgView = BlueIntent.BezierPath.View(frame: bounds)
      bgView.backgroundColor = UIColor.yellow.withAlphaComponent(0.1)
      context.bi.add(bgView)
      
      // image
      var coverView = BlueIntent.BezierPath.View()
      coverView.frame = CGRect(x: 10, y: 100, width: 100, height: 100)
      coverView.image = UIImage(data: (try? Data(contentsOf: URL(string: "https://img2.baidu.com/it/u=1328379090,2543063867&fm=26&fmt=auto&gp=0.jpg")!))!)
      coverView.contentMode = .scaleAspectFitWidth
      coverView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
      coverView.shadow = NSShadow().bi.let { (it) in
        it.shadowColor = UIColor.black.withAlphaComponent(0.3)
        it.shadowOffset = CGSize(width: 0, height: 16)
        it.shadowBlurRadius = 40
      }.base
      context.bi.add(coverView)
      
      // text
      var titleLabel = BlueIntent.BezierPath.Label()
      titleLabel.frame = CGRect.zero.bi.var { (rect) -> CGRect in
        let x = coverView.frame.maxX + 20
        let y = coverView.frame.origin.y
        let width = bounds.width - x - 20
        let height = coverView.frame.height
        return CGRect(x: x, y: y, width: width, height: height)
      }
      titleLabel.backgroundColor = UIColor.red.withAlphaComponent(0.1)
      titleLabel.text = NSAttributedString(string: "En un lugar de la Mancha, de cuyo nombre no quiero acordarme, no ha mucho tiempo que vivía un hidalgo de los de lanza en astillero, adarga antigua, rocín flaco y galgo corredor")
      titleLabel.maximumNumberOfRows = 2
      context.bi.add(titleLabel)
    }
    
    let canvasView = CanvasView(frame: CGRect.zero.bi.var { (rect) -> CGRect in
      let x: CGFloat = 0
      let y = self.view.bounds.height / 2.0
      let width = self.view.bounds.width
      let height = self.view.bounds.height - y
      return CGRect(x: x, y: y, width: width, height: height)
    })
    canvasView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
    view.addSubview(canvasView)
  }
  
}

