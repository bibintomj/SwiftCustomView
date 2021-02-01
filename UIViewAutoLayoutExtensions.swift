//
//  UIViewAutoLayoutExtensions.swift
//  Quickerala
//
//  Created by Bibin on 19/06/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

extension UIView {
    
    /// This will pin the view to the edges of superview's anchor.
    ///
    /// - Parameters:
    ///   - leadingInset: Edge from leading edge (mostly left; may change based on language) of super view.
    ///   - trailingInset: Edge from trailing edge (mostly left; may change based on language) of super view.
    ///   - topInset: distance from top of the superView.
    ///   - bottomInset: distance from the bottom of the superView.
    func pinInSuperView(leadingInset: CGFloat? = nil,
                        trailingInset: CGFloat? = nil,
                        topInset: CGFloat? = nil,
                        bottomInset: CGFloat? = nil) {
        guard superview != nil else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // X-Axis Constraints
        [leadingAnchor: (superview!.leadingAnchor, leadingInset),
         trailingAnchor: (superview!.trailingAnchor, trailingInset)]
            .forEach {
                guard $0.value.1 != nil else { return }
                $0.key.constraint(equalTo: $0.value.0, constant: $0.value.1!).isActive = true
        }
        
        // Y-Axis Constraints
        [topAnchor: (superview!.topAnchor, topInset),
         bottomAnchor: (superview!.bottomAnchor, bottomInset)]
            .forEach {
                guard $0.value.1 != nil else { return }
                $0.key.constraint(equalTo: $0.value.0, constant: $0.value.1!).isActive = true
        }
    }
    
    /// This will center itself in the superView's center.
    func centerInSuperView() {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        // Set center constraints
        [centerXAnchor: superview!.centerXAnchor].forEach { $0.key.constraint(equalTo: $0.value).isActive = true }
        [centerYAnchor: superview!.centerYAnchor].forEach { $0.key.constraint(equalTo: $0.value).isActive = true }
    }
    
    /// Sets the size of View using constraints.
    ///
    /// - Parameter size: The desired size of the view.
    func constraint(to size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        // Set size constraints
        [widthAnchor: size.width,
         heightAnchor: size.height].forEach { $0.key.constraint(equalToConstant: $0.value).isActive = true }
    }
}
