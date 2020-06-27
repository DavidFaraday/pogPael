//
//  ExopenseGroupTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 02/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ExpenseGroupTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryBackground: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if categoryBackground != nil {
            categoryBackground.layer.cornerRadius = categoryBackground.frame.size.width / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setupCellWith(_ expenseGroup: ExpenseGroup, backgroundColor: UIColor) {
        
        categoryImageView.image = getImageFor(expenseGroup.name)
        nameLabel.text = expenseGroup.name.capitalizingFirstLetter()
        amountLabel.text = convertToCurrency(number: expenseGroup.totalValue).replacingOccurrences(of: ".00", with: "")
        percentageLabel.text = String(format: "%.2f", expenseGroup.percent).replacingOccurrences(of: ".00", with: "") + "%"

                
        let message = expenseGroup.itemCount > 1 ? "Transactions" : "Transaction"
        
        itemCountLabel.text = "\(expenseGroup.itemCount) " + message
        
        categoryBackground.backgroundColor = backgroundColor
    }
}
