//
//  BaseCollectionViewCell.swift
//  Quickerala
//
//  Created by Bibin on 20/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    /// Set scrollView.delaysContentTouch = false for avoiding delay between touch and animation.
    /// Can be set in Storyboard also. "Delay touch down"
    /// If there are multiple scrollviews in screen, all of them has to do this.
    override var isHighlighted: Bool {
        didSet { self.animate([.scale(isHighlighted ? .down : .normal)]) }
    }
}
