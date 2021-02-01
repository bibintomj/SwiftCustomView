//
//  WarningView.swift
//  Quickerala
//
//  Created by Bibin on 28/05/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

struct WarningItem {
    let title: String
    let description: String
    let reloadHandler: (() -> Void)?
    let dismissHandler: (() -> Void)?
}

extension WarningItem {
    static var networkError: WarningItem {
        return WarningItem(title: "Oops!", description: "Some network error occured", reloadHandler: nil, dismissHandler: nil)
    }
}

final class WarningView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var reloadLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    
    var warning: WarningItem? {
        didSet {
            configureUI()
            setupGesture() 
        }
    }
    
    private var tapGesture: UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(onTapReload(_:)))
    }
    
    @IBAction private func didTapDismiss(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3,
                       animations: { self.alpha = 0 }, completion: { _ in
                        self.warning?.dismissHandler?()
                        self.removeFromSuperview()
        })
    }
}

private extension WarningView {
    func configureUI() {
        executeInMainThread { [weak self] in
            self?.titleLabel.text = self?.warning?.title
            self?.descriptionLabel.text = self?.warning?.description
            self?.reloadLabel.isHidden = self?.warning?.reloadHandler == nil
            self?.dismissButton.setTitle( self?.warning?.dismissHandler == nil ? "Dismiss" : "Go back", for: .normal)
        }
    }
    
    func setupGesture() {
        guard warning?.reloadHandler != nil else { return }
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapReload(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3,
                       animations: { self.alpha = 0 }, completion: { _ in
                        self.warning?.reloadHandler?()
                        self.removeFromSuperview()
        })
    }
}

extension WarningView {
    func present(on view: UIView, animated: Bool = true) {
        let present = {
            self.frame = view.bounds
            view.addSubview(self)
            
            if animated {
                self.alpha = 0
                UIView.animate(withDuration: 0.3, animations: { self.alpha = 1 })
            }
        }
        
        Thread.isMainThread ? present() : DispatchQueue.main.async { present() }
    }
}

extension WarningView: NibLoadable {}
