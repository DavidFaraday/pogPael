//
//  ExpenseTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 19/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    
    //MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if imageBackgroundView != nil {
            imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.size.width / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellWith(_ expense: Expense, backgroundColor: UIColor, dateFormatShort: Bool = true) {
        
        categoryImageView.image = getImageFor(expense.category ?? "")
        nameLabel.text = expense.nameDescription
        dateLabel.text = dateFormatShort ? expense.date?.shortDate() : expense.date?.longDate()

        priceLabel.text = convertToCurrency(number: expense.amount).replacingOccurrences(of: ".00", with: "")
        imageBackgroundView.backgroundColor = backgroundColor
    }

}
