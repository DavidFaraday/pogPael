//
//  CategoryCollectionViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 06/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
   
    //MARK: - IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func generateCell(categoryName: String, selectedCellIndex: IndexPath, indexPath: IndexPath) {
        let category = categoryName.lowercased() == "eatingout" ? "eating Out" : categoryName

        iconImageView.image = getImageFor(categoryName)
        nameLabel.text = category.capitalizingFirstLetter()
        nameLabel.adjustsFontSizeToFitWidth = true
        
        highlightSelectedCell(selectedIndex: selectedCellIndex, indexPath: indexPath)
    }

    
    private func highlightSelectedCell(selectedIndex: IndexPath, indexPath: IndexPath) {
        
        self.iconImageView.tintColor = UIColor(named: "collectionCellTintColor")
        self.nameLabel.textColor = UIColor(named: "collectionCellTintColor")

        if selectedIndex != indexPath {
            self.iconImageView.tintColor = .systemGray
            self.nameLabel.textColor = .systemGray
        }

    }

    
}
