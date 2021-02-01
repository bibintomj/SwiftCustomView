//
//  CPopoverPresentationManager.swift
//  Quickerala
//
//  Created by Bibin on 03/07/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

final class CPopoverPresentationManager: NSObject {

    // `sharedInstance` because the delegate property is weak - the delegate instance needs to be retained.
    private static let shared = CPopoverPresentationManager()
    
    private override init() {}
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    static func presentationController(for controller: UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        controller.modalTransitionStyle = .crossDissolve
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = shared
        presentationController.backgroundColor = controller.view.backgroundColor
        return presentationController
    }

}

extension CPopoverPresentationManager: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.canOverlapSourceViewRect = true
        popoverPresentationController.containerView?.alpha = 0
        UIView.animate(withDuration: 0.2) {
            popoverPresentationController.containerView?.alpha = 1
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        popoverPresentationController.containerView?.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            popoverPresentationController.containerView?.alpha = 0
        }, completion: { _ in popoverPresentationController.presentingViewController.dismiss(animated: false) })
        
        return false
    }
}
