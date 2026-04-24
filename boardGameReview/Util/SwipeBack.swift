//
//  SwipeBack.swift
//  boardGameReview
//
//  Re-enables the system edge-swipe-to-go-back gesture on screens that
//  hide the default back button via .navigationBarBackButtonHidden(true).
//

import UIKit
import ObjectiveC

private final class PopGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}

private var popDelegateKey: UInt8 = 0

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        let delegate = PopGestureDelegate()
        delegate.navigationController = self
        objc_setAssociatedObject(self, &popDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        interactivePopGestureRecognizer?.delegate = delegate
    }
}
