//
//  BlueIntentControllerTransitioning.swift
//  BlueIntentControllerTransitioning_Example
//
//  Created by zhifei qiu on 2021/6/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BlueIntent

private var BlueIntentControllerTransitioningKey = 0

public extension BlueIntent {
  struct ControllerTransitioning { }
}

public protocol BlueIntentControllerTransitioningDataDeleate {
  // 注册该 data 的 handler
  func register()
  // 绑定该 data 的 controller
  func bind(_ controller: UIViewController?) -> BlueIntentControllerTransitioningDataDeleate
}

public protocol BlueIntentControllerTransitioningDeleate: UIViewControllerTransitioningDelegate {
  static func canBind(_ data: BlueIntentControllerTransitioningDataDeleate) -> Bool
  static func bind(_ data: BlueIntentControllerTransitioningDataDeleate) -> Self?
  
  var gestureRecognizers: [UIGestureRecognizer] { set get }
  var data: BlueIntentControllerTransitioningDataDeleate { get }
}

extension BlueIntent.ControllerTransitioning {
  static var transitionings: [BlueIntentControllerTransitioningDeleate.Type] = []
  
  public static func register(_ transitioningClazz: BlueIntentControllerTransitioningDeleate.Type) {
    if transitionings.contains(where: { it in return type(of: it) == type(of: transitioningClazz) }) {
      return
    }
    transitionings.append(transitioningClazz)
  }
  
  public static func unregister(_ transitioningClazz: BlueIntentControllerTransitioningDeleate.Type) {
    if let index = transitionings.firstIndex(where: { it in return type(of: it) == type(of: transitioningClazz) }) {
      transitionings.remove(at: index)
    }
  }
}

public extension BlueIntentExtension where Base: UIViewController {
  var transitioningData: BlueIntentControllerTransitioningDataDeleate? {
    set {
      let controller = base
      if let newValue = newValue {
        newValue.register()
        let transitionings = BlueIntent.ControllerTransitioning.transitionings
        for transitioningClazz in transitionings {
          if transitioningClazz.canBind(newValue) {
            if let transitioning = transitioningClazz.bind(newValue.bind(controller)) {
              objc_setAssociatedObject(controller, &BlueIntentControllerTransitioningKey, transitioning, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
              controller.transitioningDelegate = transitioning
              controller.modalPresentationStyle = .custom
            }
            return
          }
        }
        return
      }
      
      if let transitioning = base.transitioningDelegate as? BlueIntentControllerTransitioningDeleate {
        for gesture in transitioning.gestureRecognizers {
          gesture.view?.removeGestureRecognizer(gesture)
        }
        transitioning.gestureRecognizers.removeAll()
      }
      controller.transitioningDelegate = nil
      objc_setAssociatedObject(controller, &BlueIntentControllerTransitioningKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    get {
      let controller = base
      let data = (controller.transitioningDelegate as? BlueIntentControllerTransitioningDeleate)?.data
      return data
    }
  }
}


