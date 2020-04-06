//
//  CategoryDetailTableViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 03/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class CategoryDetailTableViewController: UITableViewController {

    //MARK: - Vars
    var currentPeriodFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
    var currentPredicate: NSPredicate?

    
    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var sortPopupView: SortPopUpMenuController!

    var selectedCategoryName: String?
    
    var isSortPopUpVisible = false
    var forAllPeriod = false
    var forExpense = false

    //MARK: - view Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            let customTapBar = self.tabBarController as! CustomTabBarController
            customTapBar.showCenterButton()
        }
        
        if selectedCategoryName != nil {
            
            if forAllPeriod {
                
                currentPredicate = NSPredicate(format: "isExpense == %i && userId = %@ && category = %@", forExpense, UserAccount.currentAccount()?.id?.uuidString ?? "", selectedCategoryName!)
                
            } else {
                currentPredicate = NSPredicate(format: "isExpense == %i && year = %i && monthOfTheYear = %i && userId = %@ && category = %@", forExpense, currentYear!, currentMonth!, UserAccount.currentAccount()?.id?.uuidString ?? "", selectedCategoryName!)
            }
            

            reloadData(predicate: currentPredicate)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCurrentDate()
        
        self.navigationItem.title = selectedCategoryName
        reloadData(predicate: currentPredicate)

        tableView.tableFooterView = UIView()
        setupBarButtons()
        setupPopUpViews()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return currentPeriodFetchResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return currentPeriodFetchResultsController.sections?[section].numberOfObjects ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionTableViewCell
        
        cell.generateCell(expense: currentPeriodFetchResultsController.object(at: indexPath) as! Expense)
        
        return cell
    }
    
    //MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.currentPeriodFetchResultsController.sections?[section].name ?? ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let editVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addItemVC") as! AddExpenseViewController
        editVc.expenseToEdit = currentPeriodFetchResultsController.object(at: indexPath) as? Expense
        
        let customTapBar = self.tabBarController as! CustomTabBarController
        customTapBar.hideCenterButton()
        
        self.navigationController?.pushViewController(editVc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            context.delete(currentPeriodFetchResultsController.object(at: indexPath) as! NSManagedObject)
            appDelegate.saveContext()
        }
    }



    //MARK: - Fetch from CD

    func reloadData(predicate: NSPredicate? = nil, sortBy: String = "") {
        
        switch sortBy {
        case "date":
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "dateString", ascending: false),
                                                            NSSortDescriptor(key: "amount", ascending: false)
                                                            ]

            currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "dateString", cacheName: nil)

        default:
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "amount", ascending: false) ]

            currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

            
        }

        currentPeriodFetchResultsController.fetchRequest.predicate = predicate
        currentPeriodFetchResultsController.delegate = self

        
        do {
            try currentPeriodFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }
        

        self.tableView.reloadData()
    }


    //MARK: - Setup
    private func setupCurrentDate() {
        currentMonth = calendarComponents(Date()).month
        currentWeek = calendarComponents(Date()).weekOfYear
        currentYear = calendarComponents(Date()).year
    }
    
    private func setupBarButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: self, action: #selector(sortButtonPressed))
    }
    
    private func setupPopUpViews() {
        
        sortPopupView = SortPopUpMenuController()
        sortPopupView.contentView.layer.cornerRadius = 20
        sortPopupView.delegate = self
        sortPopupView.frame = CGRect(x: 0, y: self.view.frame.height
            + 90, width: self.view.frame.width, height: 200)
                
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow!.addSubview(sortPopupView)
        
    }


    //MARK: - Actions
    @objc private func sortButtonPressed() {
        
        isSortPopUpVisible ? hideSortPopUpView() : showSortPopUpView()
        isSortPopUpVisible.toggle()

    }

    //MARK: - Animations
    func showSortPopUpView() {
        UIView.animate(withDuration: 0.3) {
            self.sortPopupView.frame.origin.y = AnimationManager.screenBounds.maxY - (self.sortPopupView.frame.height - 20)
        }

    }
    
    func hideSortPopUpView() {
        UIView.animate(withDuration: 0.3) {
            self.sortPopupView.frame.origin.y = AnimationManager.screenBounds.maxY + 1
        }

    }


}


extension CategoryDetailTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        self.tableView.reloadData()
    }
}


extension CategoryDetailTableViewController: SortPopupMenuControllerDelegate {
    
    func dateButtonPressed() {

        reloadData(predicate: currentPredicate, sortBy: "date")

        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    func amountButtonPressed() {

        reloadData(predicate: currentPredicate, sortBy: "amount")

        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    func categoryButtonPressed() {

        reloadData(predicate: currentPredicate, sortBy: "category")
        hideSortPopUpView()
        isSortPopUpVisible.toggle()

    }
    
    func sortBackgroundTapped() {
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
        
}
