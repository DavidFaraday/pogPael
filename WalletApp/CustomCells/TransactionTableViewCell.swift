//
//  TransactionTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 29/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(expense: Expense) {
        if expense.category != nil {
            categoryImageView.image = getImageFor(expense.category ?? "")
        }
        descriptionLabel.text = expense.nameDescription
        amountLabel.text = convertToCurrency(number: expense.amount).replacingOccurrences(of: ".00", with: "")
        dateLabel.text = expense.date?.longDate()
        amountLabel.textColor = ColorFromExpenseType(expense.isExpense)
    }


}
