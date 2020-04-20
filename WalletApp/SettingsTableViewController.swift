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
        updateLogOutBarButtonItem()
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
        
        if sender.isOn && FUser.currentUser() == nil{
            
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView") as! LoginViewController
            loginVC.delegate = self
            
            self.present(loginVC, animated: true, completion: nil)
        }
        
        updateSettingsInUserDefaults(shouldSync: sender.isOn)
        
        if sender.isOn && FUser.currentUser() != nil {
            syncLocalDbToCloud()
        }
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

    private func updateLogOutBarButtonItem() {

        if FUser.currentUser() != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOutUser))
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func updateSettingsInUserDefaults(shouldSync: Bool) {
        
        userDefaults.set(shouldSync, forKey: kSYNCTOCLOUD)
        userDefaults.synchronize()
    }
    
    //MARK: - Update UI
    private func updateSyncIndicator() {
        
        if FUser.currentUser() != nil {

            self.cloudSyncSwitchOutlet.isOn = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        } else {
            self.cloudSyncSwitchOutlet.isOn = false
        }
    }


    //MARK: - LogOut
    @objc func logOutUser() {
        FUser.logOutCurrentUser { (error) in
            
            if error == nil {

                self.updateLogOutBarButtonItem()
                self.updateSyncIndicator()
                
                self.updateSettingsInUserDefaults(shouldSync: self.cloudSyncSwitchOutlet.isOn)
            } else {
                print("Couldn't logout user", error!.localizedDescription)
            }
        }
    }

    //MARK: - CloudUpdate
    private func syncLocalDbToCloud() {

        CloudManager.sharedManager.uploadAllAccountsToCloud(allAccounts: fetchAllAccounts())
        CloudManager.sharedManager.uploadAllExpensesToCloud(allExpenses: fetchAllExpenses())
    }
    
    private func fetchAllExpenses() -> [Expense] {
        
        var allExpenses: [Expense] = []
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = []
        
        do {
            allExpenses = try context.fetch(fetchRequest) as! [Expense]
            
        } catch {
            print("Failed to fetch account")
        }
        
        return allExpenses
    }
    
    private func fetchAllAccounts() -> [Account] {
        
        var allAccounts: [Account] = []
        
        let context = AppDelegate.context
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.sortDescriptors = []
        
        do {
            allAccounts = try context.fetch(fetchRequest) as! [Account]
            
        } catch {
            print("Failed to fetch account")
        }
        
        
        return allAccounts
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

extension SettingsTableViewController: LoginViewControllerDelegate {
    
    func didDismiss() {

        updateSyncIndicator()
        updateLogOutBarButtonItem()
    }    
}
