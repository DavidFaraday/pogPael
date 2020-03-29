//
//  AccountsViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 27/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class AccountsViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var topBackground: UIView!
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var incomesLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    //MARK: - Vars
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var account: Account?


    //MARK: - ViewLifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        showCurrentAccountDetails()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //MARK: - IBActions
    @IBAction func optionButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "accountToAddAccountSeg", sender: UserAccount.currentAccount())
    }
    
    @IBAction func menuBarButtonItemPressed(_ sender: Any) {
        
        let allAccountsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "allAccountsVC") as! AllAccountsViewController
        allAccountsVC.delegate = self
        
        present(allAccountsVC, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - SetupUI
    private func setupUI() {
        
        backgroundView.layer.cornerRadius = 10
        
        self.topBackground.applyGradient(colors: [
            UIColor(named: "gradientStartColor")!.cgColor,
            UIColor(named: "gradientEndColor")!.cgColor],
                                         locations: [0.0, 1.0],
                                         direction: .leftToRight, cornerRadius: 10)
        
        //        let gradientLayer = CAGradientLayer()
        //        gradientLayer.frame = self.topBackground.bounds
        //        gradientLayer.colors = [UIColor(named: "gradientStartColor")!.cgColor, UIColor(named: "gradientEndColor")!.cgColor]
        //        self.topBackground.layer.insertSublayer(gradientLayer, at: 0)
        //        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        //        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        //        gradientLayer.cornerRadius = 10
        //        gradientLayer.maskedCorners
        //            = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        topBackground.layer.cornerRadius = 10
        topBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    //MARK: - FetchCoreData

    private func loadAccountDetails() {
        
        if account != nil {
            
            accountNameLabel.text = account!.name
            
            if account!.image != nil {
                avatarImageView.image = UIImage(data: account!.image!)?.circleMasked
            }
        }
    }
    
    private func loadExpenses() {
        
        if account != nil {
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "amount", ascending: false) ]

            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self
            
            fetchResultsController.fetchRequest.predicate = NSPredicate(format: "userId == %@", account!.id!.uuidString)

            do {
                try fetchResultsController.performFetch()
            } catch {
                fatalError("error fetching")
            }
            
            separateExpenses()

        }

    }
    
    //MARK: - Helpers
    func separateExpenses() {
        
        var totalIncoming = 0.0
        var totalExpense = 0.0
        
        for expense in fetchResultsController.fetchedObjects! {
            
            let tempExpense = expense as! Expense
            
            if tempExpense.isExpense {
                totalExpense += tempExpense.amount
            } else {
                totalIncoming += tempExpense.amount
            }
            
        }
        
        updateUI(incoming: totalIncoming, expense: totalExpense)
    }
    
    private func showCurrentAccountDetails() {
        account = UserAccount.currentAccount()

        setupUI()
        loadAccountDetails()
        loadExpenses()
    }

    
    //MARK: - UpdateUI

    func updateUI(incoming: Double, expense: Double) {
        
        let balance = convertToCurrency(number: incoming - expense)
        let incoming = convertToCurrency(number: incoming)
        let expense = convertToCurrency(number: expense)
        
        let total = NSMutableAttributedString()
        total.append(NSAttributedString(string: "Total Balance = "))
        total.append(formatStringDecimalSize(balance, mainNumberSize: 15.0, decimalNumberSize: 10.0))

        
        totalLabel.attributedText = total
        incomesLabel.attributedText = formatStringDecimalSize(incoming, mainNumberSize: 18.0, decimalNumberSize: 10.0)
        expensesLabel.attributedText = formatStringDecimalSize(expense, mainNumberSize: 18.0, decimalNumberSize: 10.0)
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "accountToAddAccountSeg" {
            let destinationVC = segue.destination as! AddAccountViewController
            destinationVC.delegate = self
            

            if sender is Account {
                destinationVC.accountToEdit = sender as? Account
            }
        }
        
    }



}


extension AccountsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        separateExpenses()
    }
}


extension AccountsViewController: AddAccountViewControllerDelegate {
    
    func didCreateAccount() {
        showCurrentAccountDetails()
    }
    
}


extension AccountsViewController: AllAccountsViewControllerDelegate {
    
    func didSelectAccount() {
        showCurrentAccountDetails()
    }

}
