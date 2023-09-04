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

    let label1 = UILabel()
    label1.text = "test1"
    label1.backgroundColor = .blue


    let label2 = UILabel()
    label2.text = "test2"
    label2.backgroundColor = .blue
    label2.font = .systemFont(ofSize: 30)


    let rowLayout = FlexStackView.RowLayout(minimumLineSpacing: 8,
                                            minimumInteritemSpacing: 8,
                                            alignItems: .center,
                                            lineLint: 12)

    let stackView = FlexStackView(layout: rowLayout)
    stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    stackView.directionalLayoutMargins = .zero
    stackView.backgroundColor = .yellow
    stackView.frame = CGRect(x: 0, y: 100, width: 50, height: 30)
    stackView.addArrangedSubview(label1)
    stackView.addArrangedSubview(label2)

    view.addSubview(stackView)

    let label3 = UILabel()
    label3.text = "test3444444445"
    label3.backgroundColor = .blue
    stackView.addArrangedSubview(label3)

    let label4 = UILabel()
    label4.text = "test4"
    label4.backgroundColor = .blue
    label4.font = .systemFont(ofSize: 30)
    stackView.addArrangedSubview(label4)
    
    let layout: FlexStackView.RowLayout? = (stackView.layout as? FlexStackView.RowLayout)
    layout?.setCustomInteritemSpacing(0, after: label1)
    layout?.setCustomInteritemSpacing(0, after: label3)
    
    stackView.frame = {
      var frame = stackView.frame
      frame.size = stackView.sizeThatFits(width: 240)
      return frame
    }()

//    layout?.setCustomInteritemSpacing(FlexStackView.RowLayout.spacingUseDefault, after: stackView.arrangedSubviews.firstIndex(of: label1))
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

