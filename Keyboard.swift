//
//  Keyboard.swift
//  ChatDemo
//
//  Created by Bibin on 17/12/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

class Keyboard {
    
    enum Event { case willShow, didShow, willHide, didHide }
    
    private static var _shared = Keyboard()
    static var shared: Keyboard { _shared }
    
    private init() {}
    
    var onEvent: ((_: Event, _: Payload) -> Void)? {
        didSet {
            guard self.onEvent != nil else { self.removeObservers(); return }
            self.addObservers()
        }
    }
}

private extension Keyboard {
    var observerMap: [NSNotification.Name: Selector] {
        [UIWindow.keyboardWillShowNotification: #selector(self.onWillShow),
         UIWindow.keyboardDidShowNotification: #selector(self.onDidShow),
         UIWindow.keyboardWillHideNotification: #selector(self.onWillHide),
         UIWindow.keyboardDidHideNotification: #selector(self.onDidHide)]
    }
    func addObservers() {
        observerMap.forEach {
            NotificationCenter.default.removeObserver(self, name: $0.key, object: nil)
            NotificationCenter.default.addObserver(self, selector: $0.value, name: $0.key, object: nil)
        }
    }
    
    func removeObservers() {
        observerMap.forEach {
            NotificationCenter.default.removeObserver(self, name: $0.key, object: nil)
        }
    }
}

private extension Keyboard {
    @objc func onWillShow(notification: Notification) {
        let payload = Payload(with: notification)
        guard payload.endFrame.size.height > 200 else { return }
        onEvent?(.willShow, payload)
    }
    @objc func onDidShow(notification: Notification) {
        let payload = Payload(with: notification)
        guard payload.endFrame.size.height > 200 else { return }
        onEvent?(.didShow, payload)
    }
    
    @objc func onWillHide(notification: Notification) {
        let payload = Payload(with: notification)
        guard payload.beginFrame.size.height > 200 else { return }
        onEvent?(.willHide, payload)
    }
    
    @objc func onDidHide(notification: Notification) {
        let payload = Payload(with: notification)
        guard payload.beginFrame.size.height > 200 else { return }
        onEvent?(.didHide, payload)
    }
}

extension Keyboard {
    struct Payload {
        let beginFrame: CGRect
        let endFrame: CGRect
        let curve: UIView.AnimationCurve
        let duration: TimeInterval
        let isLocal: Bool
    }
}

extension Keyboard.Payload {
    init(with notification: Notification) {
        let userInfo = notification.userInfo
        beginFrame = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        endFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        curve = UIView.AnimationCurve(rawValue: userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0) ?? .easeOut
        duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        isLocal = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool ?? false
    }
}

