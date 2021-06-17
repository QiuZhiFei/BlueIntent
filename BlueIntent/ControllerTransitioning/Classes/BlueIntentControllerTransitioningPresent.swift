//
//  BlueIntentControllerTransitioningPresent.swift
//  BlueIntentControllerTransitioning_Example
//
//  Created by zhifei qiu on 2021/6/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BlueIntent

public extension BlueIntent.ControllerTransitioning.Present {
  // 关闭方式
  enum PanGestureRecognizerEdgeType {
    case leftToRight       // 左 - 右 关闭
    case topToBottom       // 上 - 下 关闭
  }
}

extension BlueIntent.ControllerTransitioning.Present.Data: BlueIntentCompatible { }

public extension Optional where Wrapped == BlueIntentControllerTransitioningDataDeleate {
  static var present: BlueIntent.ControllerTransitioning.Present.Data {
    return BlueIntent.ControllerTransitioning.Present.Data()
  }
}

extension BlueIntent.ControllerTransitioning.Present {
  public struct Data: BlueIntentControllerTransitioningDataDeleate {
    public var transitionDuration = Constant.transitionDuration
    public var maskColor = Constant.maskColor
    public var edgeTypes: [PanGestureRecognizerEdgeType] = [.leftToRight]
    weak var controller: UIViewController?
    
    public init() { }
    
    public func register() {
      BlueIntent.ControllerTransitioning.register(BlueIntent.ControllerTransitioning.Present.self)
    }
    
    public func bind(_ controller: UIViewController?) -> BlueIntentControllerTransitioningDataDeleate {
      var data = self
      data.controller = controller
      return data
    }
  }
}

extension BlueIntent.ControllerTransitioning.Present {
  struct Constant {
    static let viewKey = "view"
    static let transitionDuration = 0.35
    static let maskColor = UIColor.black.withAlphaComponent(0.15)
  }
}

public extension BlueIntent.ControllerTransitioning {
  final class Present: NSObject, BlueIntentControllerTransitioningDeleate {
    public var gestureRecognizers: [UIGestureRecognizer] = []
    public var data: BlueIntentControllerTransitioningDataDeleate
    // present 动画
    private let presentedAnimatedTransitioning = PresentedAnimatedTransitioning()
    // dismiss 动画
    private let dismissedAnimatedTransitioning = DismissedAnimatedTransitioning()
    // dismiss 动画控制
    private var dismissedPercentDrivenTransition: UIPercentDrivenInteractiveTransition?
    var controller: UIViewController? {
      return (data as? Data)?.controller
    }
    
    init(data: BlueIntentControllerTransitioningDataDeleate) {
      self.data = data
      super.init()
      addPanGestureRecognizersIfNeeded()
    }
    
    deinit {
      KVOController?.removeObserver(self, forKeyPath: Constant.viewKey)
    }
    
    public static func canBind(_ data: BlueIntentControllerTransitioningDataDeleate) -> Bool {
      return data is Data
    }
    
    public static func bind(_ data: BlueIntentControllerTransitioningDataDeleate) -> Self? {
      guard let data = data as? Data else { return nil }
      return Self.init(data: data)
    }
  }
}

// MARK: - UIViewControllerTransitioningDelegate

public extension BlueIntent.ControllerTransitioning.Present {
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self.dismissedAnimatedTransitioning
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return self.dismissedPercentDrivenTransition
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self.presentedAnimatedTransitioning
  }
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return PresentationController(presentedViewController: presented, presenting: presenting)
  }
}

// MARK: - Data

extension BlueIntentExtension where Base: UIViewController {
  var presentTransitioningData: BlueIntent.ControllerTransitioning.Present.Data? {
    return self.transitioningData as? BlueIntent.ControllerTransitioning.Present.Data
  }
}

// MARK: - GestureRecognizer

private extension BlueIntent.ControllerTransitioning.Present {
  class ScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {
    // 处理手势冲突，自身属性是否失效, return false 则自身失效
    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      if otherGestureRecognizer.view is UIScrollView {
        // 手势冲突来自 ScrollView，则优先 PanGestureRecognizer
        return true
      }
      return false
    }
  }
  
  class PanGestureRecognizer: UIPanGestureRecognizer { }
  
  @objc
  func handleEdgePanGesture(gesture: UIGestureRecognizer) {
    guard let window = gesture.view?.window else { return }
    guard let gesture = gesture as? ScreenEdgePanGestureRecognizer else { return }
    let controller = self.controller
    
    let progress = abs(gesture.translation(in: window).x) / window.bounds.width
    
    if gesture.state == .began {
      self.dismissedPercentDrivenTransition = UIPercentDrivenInteractiveTransition()
      controller?.dismiss(animated: true, completion: nil)
    } else if gesture.state == .changed {
      self.dismissedPercentDrivenTransition?.update(progress)
    } else if gesture.state == .cancelled || gesture.state == .ended {
      let velocity = gesture.velocity(in: gesture.view)
      if progress > 0.5 || velocity.x > 200 {
        self.dismissedPercentDrivenTransition?.finish()
      } else {
        self.dismissedPercentDrivenTransition?.cancel()
      }
      self.dismissedPercentDrivenTransition = nil
    }
  }
  
  @objc
  func handlePanGesture(gesture: UIGestureRecognizer) {
    guard let window = gesture.view?.window else { return }
    guard let gesture = gesture as? PanGestureRecognizer else { return }
    let controller = self.controller
    
    let progress = abs(gesture.translation(in: window).y) / window.bounds.height
    
    if gesture.state == .began {
      self.dismissedPercentDrivenTransition = UIPercentDrivenInteractiveTransition()
      controller?.dismiss(animated: true, completion: nil)
    } else if gesture.state == .changed {
      self.dismissedPercentDrivenTransition?.update(progress)
    } else if gesture.state == .cancelled || gesture.state == .ended {
      let velocity = gesture.velocity(in: gesture.view)
      if progress > 0.5 || velocity.y > 200 {
        self.dismissedPercentDrivenTransition?.finish()
      } else {
        self.dismissedPercentDrivenTransition?.cancel()
      }
      self.dismissedPercentDrivenTransition = nil
    }
  }
}

private extension BlueIntent.ControllerTransitioning.Present {
  var KVOController: UIViewController? {
    if let controller = controller as? UINavigationController {
      return controller.viewControllers.first
    }
    return controller
  }
  
  func addPanGestureRecognizersIfNeeded() {
    guard let controller = self.controller else { return }
    if controller.isViewLoaded {
      addPanGestureRecognizers(controller.view)
    } else {
      KVOController?.addObserver(self, forKeyPath: Constant.viewKey, options: .new, context: nil)
    }
  }
  
  func addPanGestureRecognizers(_ view: UIView?) {
    guard let view = view else { return }
    let controller = self.controller
    
    let edgeTypes = (self.data as? Data)?.edgeTypes ?? []
    if let _ = edgeTypes.firstIndex(of: .leftToRight) {
      let pan = ScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(gesture:)))
      pan.edges = .left
      view.addGestureRecognizer(pan)
      gestureRecognizers.append(pan)
    }
    if let _ = edgeTypes.firstIndex(of: .topToBottom) {
      let pan = PanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
      view.addGestureRecognizer(pan)
      gestureRecognizers.append(pan)
    }
    
    // ScreenEdgePanGestureRecognizer 优先级高
    let edgePans = gestureRecognizers.filter { gesture in
      return gesture is ScreenEdgePanGestureRecognizer
    }
    let pans = gestureRecognizers.filter { gesture in
      return gesture is PanGestureRecognizer
    }
    if edgePans.count > 0, pans.count > 0 {
      for pan in pans {
        for edgePan in edgePans {
          pan.require(toFail: edgePan)
        }
      }
    }
    
    // interactivePopGestureRecognizer 优先级高
    // build release 时，panGesture 会与 interactivePopGestureRecognizer 冲突，导致手势左滑时，会触发 panGesture 的 dimiss
    // debug 下正常，奇怪 ...
    if let interactivePopGestureRecognizer = (controller as? UINavigationController)?.interactivePopGestureRecognizer {
      for gesture in gestureRecognizers {
        gesture.require(toFail: interactivePopGestureRecognizer)
      }
    }
  }
}

extension BlueIntent.ControllerTransitioning.Present {
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let keyPath = keyPath, keyPath == Constant.viewKey {
      addPanGestureRecognizers(self.controller?.view)
    }
  }
}

// MARK: - PresentationController

extension BlueIntent.ControllerTransitioning.Present {
  final class PresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
      return false
    }
    
    override func presentationTransitionWillBegin() {
      super.presentationTransitionWillBegin()
      guard let presentTransitioningData = presentedViewController.bi.presentTransitioningData else { return }
      
      self.containerView?.backgroundColor = .clear
      _ = presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (_) in
        guard let `self` = self else { return }
        self.containerView?.backgroundColor = presentTransitioningData.maskColor
      }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
      super.dismissalTransitionWillBegin()
      guard let _ = presentedViewController.bi.presentTransitioningData else { return }
      
      _ = presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
        self.containerView?.backgroundColor = .clear
      }, completion: nil)
    }
  }
}

// MARK: - PresentedAnimatedTransitioning

extension BlueIntent.ControllerTransitioning.Present {
  final class PresentedAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      let toVC = transitionContext?.viewController(forKey: .to)
      let transitionDuration = toVC?.bi.presentTransitioningData?.transitionDuration ?? Constant.transitionDuration
      return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard
        let fromVC = transitionContext.viewController(forKey: .from),
        let toVC = transitionContext.viewController(forKey: .to) else {
        return
      }
      
      let containerView = transitionContext.containerView
      let screenBounds = containerView.bounds
      let startFrame = CGRect(origin: CGPoint(x: 0, y: screenBounds.height),
                              size: screenBounds.size)
      let finalFrame = CGRect(origin: CGPoint(x: 0, y: 0),
                              size: screenBounds.size)
      
      // fromVC viewWillDisappear
      fromVC.beginAppearanceTransition(false, animated:true)
      
      toVC.view.frame = startFrame
      containerView.addSubview(toVC.view)
      
      UIView.animate(
        withDuration: transitionDuration(using: transitionContext)) {
        toVC.view.frame = finalFrame
      } completion: { (_) in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        fromVC.endAppearanceTransition()
      }
    }
  }
}

// MARK: - DismissedAnimatedTransitioning

extension BlueIntent.ControllerTransitioning.Present {
  final class DismissedAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      let fromVC = transitionContext?.viewController(forKey: .from)
      let transitionDuration = fromVC?.bi.presentTransitioningData?.transitionDuration ?? Constant.transitionDuration
      return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
        return
      }
      
      let containerView = transitionContext.containerView
      let screenBounds = containerView.bounds
      let finalFrame = CGRect(origin: CGPoint(x: 0, y: screenBounds.height),
                              size: screenBounds.size)
      
      // 上一页 viewWillAppear
      toVC.beginAppearanceTransition(true, animated:true)
      
      UIView.animate(
        withDuration: transitionDuration(using: transitionContext),
        animations: {
          fromVC.view.frame = finalFrame
        },
        completion: { _ in
          if transitionContext.transitionWasCancelled {
            // 滑动取消
            // 上一页 viewWillDisappear
            toVC.beginAppearanceTransition(false, animated:true)
            // 上一页 viewDidDisappear
            toVC.endAppearanceTransition() // *
          } else {
            // 滑动结束
            // 上一页 viewDidAppear
            toVC.endAppearanceTransition()
          }
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
      )
    }
  }
}

