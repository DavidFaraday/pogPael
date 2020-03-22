//
//  TransactionsViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 01/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var thisPeriodLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    //MARK: Class vars
    var currentPeriodFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var allTimeFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let predicate = NSPredicate(format: "isExpense == %@", NSNumber(value: false))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            let customTapBar = self.tabBarController as! CustomTabBarController
            customTapBar.showCenterButton()
        }
        
        reloadData()
        calculateAmounts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentPeriod()
        fetchAllPeriod()
        tableView.tableFooterView = UIView()
    }
    

    //MARK: Fetching Data
    
    private func fetchAllPeriod() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = [ ]
        
        allTimeFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        allTimeFetchResultsController.delegate = self
        
        do {
            try allTimeFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }

    }

    private func fetchCurrentPeriod() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "category", ascending: false), NSSortDescriptor(key: "amount", ascending: false) ]
        
        currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)
        currentPeriodFetchResultsController.delegate = self
    }
    
    func reloadData(predicate: NSPredicate? = nil, sortBy: String? = nil) {
        
        if sortBy != nil {
            let sort = NSSortDescriptor(key: sortBy!, ascending: false)
            currentPeriodFetchResultsController.fetchRequest.sortDescriptors = [sort]
        }

        if predicate != nil {
            currentPeriodFetchResultsController.fetchRequest.predicate = predicate
        }
        
        do {
            try currentPeriodFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }
        
        tableView.reloadData()
    }


    
    //MARK: UpdateUI
    private func updateUI(total: Double, thisPeriod: Double) {
        
        let totalString = convertToCurrency(number: total)
        let thisPeriodString = convertToCurrency(number: thisPeriod)
        
        
        totalLabel.attributedText = formatStringDecimalSize(totalString, mainNumberSize: 20.0, decimalNumberSize: 10.0)
        totalLabel.textColor = ColorFromAmount(total)
        
        thisPeriodLabel.attributedText = formatStringDecimalSize(thisPeriodString, mainNumberSize: 20.0, decimalNumberSize: 10.0)
        thisPeriodLabel.textColor = ColorFromAmount(thisPeriod)
    }

    //MARK: - Calculate totals
    
    private func calculateAmounts() {
        
        updateUI(total: calculateThisPeriod(), thisPeriod: calculateAllPeriod())
    }
    
    private func calculateThisPeriod() -> Double {
        
        var tempIncoming = 0.0
        var tempExpense = 0.0
        
        for expense in currentPeriodFetchResultsController.fetchedObjects! {
            let tempExp = expense as! Expense
            
            if tempExp.isExpense {
                tempExpense += tempExp.amount
            } else {
                tempIncoming += tempExp.amount
            }
        }
        
        return tempIncoming - tempExpense
    }
    
    private func calculateAllPeriod() -> Double {

        var tempIncoming = 0.0
        var tempExpense = 0.0
        
        for expense in allTimeFetchResultsController.fetchedObjects! {
            let tempExp = expense as! Expense
            
            if tempExp.isExpense {
                tempExpense += tempExp.amount
            } else {
                tempIncoming += tempExp.amount
            }
        }
        
        return tempIncoming - tempExpense
    }



}

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        calculateAmounts()
        tableView.reloadData()
    }
}


extension TransactionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return currentPeriodFetchResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return currentPeriodFetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionTableViewCell
        
        cell.generateCell(expense: currentPeriodFetchResultsController.object(at: indexPath) as! Expense)
        
        return cell
    }
    

}

extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.currentPeriodFetchResultsController.sections?[section].name ?? ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let editVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addItemVC") as! AddExpenseViewController
        editVc.expenseToEdit = currentPeriodFetchResultsController.object(at: indexPath) as? Expense
        
        let customTapBar = self.tabBarController as! CustomTabBarController
        customTapBar.hideCenterButton()
        
        self.navigationController?.pushViewController(editVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            context.delete(currentPeriodFetchResultsController.object(at: indexPath) as! NSManagedObject)
            appDelegate.saveContext()
        }
    }
}
