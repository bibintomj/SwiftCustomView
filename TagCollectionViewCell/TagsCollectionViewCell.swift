//
//  TagsCollectionViewCell.swift
//  Quickerala
//
//  Created by Bibin on 21/06/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var customContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var title: String? { didSet { titleLabel?.text = title } }
    var contentBackgroundColor: UIColor? { didSet { customContentView?.backgroundColor = contentBackgroundColor } }
    var titleColor: UIColor? { didSet { titleLabel?.textColor = titleColor } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customize()
    }
    
}

private extension TagsCollectionViewCell {
    func customize() {
        customContentView.cornerRadius = customContentView.bounds.height / 2
    }
}
