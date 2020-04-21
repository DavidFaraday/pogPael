//
//  SettingsTableViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 31/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var cloudSyncSwitchOutlet: UISwitch!
    
    
    //MARK: - View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateSyncIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    //MARK: IBActions
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        
        let text = "Hey! Check out this cool money tracker app that I am using, its called PiggyB Pro \(kAPPURL)"
        
        let objectsToShare: [Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityViewController.setValue("Check out this cool app PiggyB Pro", forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func rateOnAppStoreButtonPressed(_ sender: Any) {
        rateApp()
    }
    
    @IBAction func facebookLikeButtonPressed(_ sender: Any) {
        likeFacebook()
    }
    
    @IBAction func cloudSyncSwitchValueChanged(_ sender: UISwitch) {

        updateSettingsInUserDefaults(shouldSync: sender.isOn)

    }
    
    
    //MARK: - Helpers
    
    private func rateApp() {
        if let url = URL(string: kAPPURL) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    private func likeFacebook() {
        if let url = URL(string: kFACEBOOKURL) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }


    
    private func updateSettingsInUserDefaults(shouldSync: Bool) {
        
        userDefaults.set(shouldSync, forKey: kSYNCTOCLOUD)
        userDefaults.synchronize()
    }
    
    //MARK: - Update UI
    private func updateSyncIndicator() {
        self.cloudSyncSwitchOutlet.isOn = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false

    }



    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 2 ? 3 : 1
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
