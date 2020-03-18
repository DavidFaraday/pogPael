//
//  TransactionsViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 01/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var thisPeriodLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    //MARK: Class vars
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let predicate = NSPredicate(format: "isExpense == %@", NSNumber(value: false))
        reloadData()
        calculateAmounts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "amount", ascending: true) ]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        tableView.tableFooterView = UIView()
    }
    
    //MARK: TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionTableViewCell
        
        cell.generateCell(expense: fetchResultsController.object(at: indexPath) as! Expense)
        
        return cell
    }
    

    //MARK: Fetching Data

    func reloadData(predicate: NSPredicate? = nil, sortBy: String? = nil) {
        
        if sortBy != nil {
            let sort = NSSortDescriptor(key: sortBy!, ascending: false)
            fetchResultsController.fetchRequest.sortDescriptors = [sort]
        }
        
        if predicate != nil {
            fetchResultsController.fetchRequest.predicate = predicate
        }
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }
        
        tableView.reloadData()
    }

    
    func calculateAmounts() {
        var total = 1.0 //need to fix
        var thisPeriod = 0.0
        
        for expense in fetchResultsController.fetchedObjects! {
            let tempExpense = expense as! Expense
            thisPeriod += tempExpense.amount
        }
        
        
        updateUI(total: total, thisPeriod: thisPeriod)
    }
    
    //MARK: UpdateUI
    
    func updateUI(total: Double, thisPeriod: Double) {
        
        let total = convertToCurrency(number: total)
        let thisPeriod = convertToCurrency(number: thisPeriod)
        
        
        totalLabel.attributedText = formatStringDecimalSize(total, mainNumberSize: 20.0, decimalNumberSize: 10.0)
        thisPeriodLabel.attributedText = formatStringDecimalSize(thisPeriod, mainNumberSize: 20.0, decimalNumberSize: 10.0)
    }




}
