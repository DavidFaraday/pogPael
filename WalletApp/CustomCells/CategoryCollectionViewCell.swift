//
//  CategoryCollectionViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 06/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func generateCell(categoryName: String) {
        let category = categoryName.lowercased() == "eatingout" ? "eating Out" : categoryName

        iconImageView.image = getImageFor(categoryName)
        nameLabel.text = category.capitalizingFirstLetter()
        nameLabel.adjustsFontSizeToFitWidth = true
    }

    
}
