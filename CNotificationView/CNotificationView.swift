//
//  CNotificationView.swift
//  Quickerala
//
//  Created by Bibin on 17/06/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

final class CNotificationView: UIView {
    
    enum Anchor { case top, bottom }

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var widthConstraint: NSLayoutConstraint!
    
    static var view: CNotificationView = {
        let notificatonView = CNotificationView.instantiate()
//        notificatonView.contentView.setBorder(width: 1, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6294014085))
        notificatonView.contentViewTopConstraint.constant = -100
        return notificatonView
    }()
    
    var anchor: Anchor = .top
    var message: String = ""
    
}

extension CNotificationView {
    static func show(with message: String) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(view)
            view.contentView.backgroundColor = #colorLiteral(red: 0.9178450704, green: 0.9493189454, blue: 0.9624481797, alpha: 1)
            view.messageLabel.textColor = #colorLiteral(red: 0.9994880557, green: 0.2408709228, blue: 0.1904748976, alpha: 1)
            view.frame = UIScreen.main.bounds
            view.center = view.superview?.center ?? .zero
            view.contentView.cornerRadius = view.contentView.frame.height / 2
            view.layoutIfNeeded()

            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                view.messageLabel.text = message
                view.contentView.setShadow()
                view.contentViewTopConstraint.constant = 50
                view.layoutIfNeeded()

            }, completion: nil)
            
        }
    }
    
    static func dismiss(with message: String) {
        
        DispatchQueue.main.async {
            view.messageLabel.text = message
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                view.contentViewTopConstraint.constant = 50
                view.contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                view.messageLabel.textColor = .white
                view.layoutIfNeeded()
            })
            
            UIView.animate(withDuration: 0.6, delay: 2, options: .curveEaseIn, animations: {
                view.contentViewTopConstraint.constant = -100
                view.layoutIfNeeded()
            }, completion: { _ in view.removeFromSuperview() })
        }
    }
}

extension CNotificationView: NibLoadable {}
