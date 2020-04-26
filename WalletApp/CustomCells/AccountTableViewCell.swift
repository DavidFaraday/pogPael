//
//  AccountTableViewCell.swift
//  WalletApp
//
//  Created by David Kababyan on 28/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentAccountCheckImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func generateCell(account: Account) {
        
        if account.image != nil {
            avatarImageView.image = UIImage(data: account.image!)?.circleMasked
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle")
        }
        
        account.isCurrent ? currentAccountCheckImageView.image = UIImage(systemName: "checkmark.circle.fill") : nil
        nameLabel.text = account.name
    }

}
