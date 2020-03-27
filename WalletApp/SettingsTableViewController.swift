//
//  SettingsTableViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 31/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }

    
    //MARK: IBActions
    
    @IBAction func currenciesButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func dateFormatButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        
        let text = "Hey! Check out this cool WalletApp \(kAPPURL)"
        
        let objectsToShare: [Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityViewController.setValue("Check out this cool WalletApp", forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 1 ? 1 : 3
    }

    
    //MARK: TableViewDelegates

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "General"
        } else if section == 1 {
            return "Data Management"
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 0
    }
    


}
