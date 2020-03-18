//
//  TransactionTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 29/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(expense: Expense) {
        if expense.category != nil {
            iconImageView.image = UIImage.init(named: expense.category!)
        }
        descriptionLabel.text = expense.nameDescription
        amountLabel.text = convertToCurrency(number: expense.amount)
    }


}
