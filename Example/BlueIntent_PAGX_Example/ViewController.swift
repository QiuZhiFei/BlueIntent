//
//  ViewController.swift
//  BlueIntent_PAGX_Example
//
//  Created by zhifei qiu on 2022/7/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import BlueIntent
import libpag

class ViewController: UIViewController {
  private let pagView = PAGView(frame: .zero)
  private let slider = UISlider(frame: .zero)
  private var timer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()

    pagView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.width)
    view.addSubview(pagView)
    pagView.bi.repeats = true
    pagView.bi.play(url: "http://img2.doufine.com/pagfiles/cat.pag") { [weak self] (pagView) in
      guard let sself = self else { return }
      guard let frameRate = pagView.bi.frameRate else { return }
      sself.timer?.invalidate()
      sself.timer = Timer.scheduledTimer(timeInterval: 1 / frameRate, target: sself, selector: #selector(sself.handleSyncPagViewProgress), userInfo: nil, repeats: true)
      if let timer = sself.timer {
        RunLoop.main.add(timer, forMode: .common)
      }
    }

    slider.frame = {
      let originX: CGFloat = 40
      let originY: CGFloat = pagView.frame.maxY + 20
      let height: CGFloat = 20
      let width = view.bounds.width - originX * 2
      return CGRect(x: originX,
                    y: originY,
                    width: width,
                    height: height)
    }()
    slider.addTarget(self, action: #selector(handleSliderValueChanged(slider:)), for: .valueChanged)
    view.addSubview(slider)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    pagView.bi.repeats = !pagView.bi.repeats
    pagView.bi.play()
  }

  @objc func handleSyncPagViewProgress() {
    let value = pagView.bi.progress
    slider.value = Float(value)
  }

  @objc func handleSliderValueChanged(slider: Any) {
    let value = Double((slider as? UISlider)?.value ?? 0)
    pagView.setProgress(value)
  }
}

