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
        
        account = UserAccount.currentAccount()

        setupUI()
        loadAccountDetails()
        loadExpenses()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //MARK: - IBActions
    @IBAction func optionButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Edit Account", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (nameTextField) in
            
            nameTextField.placeholder = "Account Name"
            nameTextField.autocapitalizationType = .words
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            
            let account = UserAccount.currentAccount()
            account?.name = alertController.textFields?.first?.text
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.loadAccountDetails()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addAccountButtonPressed(_ sender: Any) {
        
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

    private func loadAccountDetails() {
        
        if account != nil {
            
            accountNameLabel.text = account!.name
            
            if account!.image != nil {
                avatarImageView.image = UIImage(data: account!.image!)
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


}


extension AccountsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        separateExpenses()
    }
}
