//
//  AllAccountsViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import CoreData


protocol AllAccountsViewControllerDelegate {
    func didSelectAccount()
}

class AllAccountsViewController: UIViewController {

    //MARK: - IBActions
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Vars
    var allAccounts: [Account] = []
    var delegate: AllAccountsViewControllerDelegate?
    
    //MARK: - ViewLifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAccounts()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    //MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - FetchData
    private func fetchAccounts() {
        
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.sortDescriptors = []
        

        do {
            allAccounts = try context.fetch(fetchRequest) as! [Account]
            
        } catch {
            print("Failed to fetch account")
        }
        
        tableView.reloadData()
    }

    
    //MARK: - Helpers
    private func setAccountAsCurrent(account: Account) {
        
        account.isCurrent = true
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

}



extension AllAccountsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AccountTableViewCell
        
        cell.generateCell(account: allAccounts[indexPath.row])
        
        return cell
    }
    
}


extension AllAccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        UserAccount.changeAccountStatus()
        setAccountAsCurrent(account: allAccounts[indexPath.row])
        
        delegate?.didSelectAccount()
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let context = AppDelegate.context
                
        if editingStyle == .delete {
            
            let accountToDelete = allAccounts[indexPath.row]
            
            if accountToDelete.isCurrent == true {
                print("cannot delete current account!")
                return
            }
            
            allAccounts.remove(at: indexPath.row)
            context.delete(accountToDelete)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            tableView.reloadData()
        }
    }

}
