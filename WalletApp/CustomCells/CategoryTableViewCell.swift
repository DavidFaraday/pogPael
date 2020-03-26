//
//  CategoryTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 31/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(categoryName: String, isChecked: Bool) {
        
        let category = categoryName.lowercased() == "eatingout" ? "eating Out" : categoryName

        iconImageView.image = UIImage.init(named: categoryName.lowercased())
        nameLabel.text = category.capitalizingFirstLetter()
        tickImageView.image = isChecked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
    }

}
