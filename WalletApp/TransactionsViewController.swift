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
    @IBOutlet weak var searchTextfield: UITextField!
    
    //MARK: Class vars
    var currentPeriodFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var allTimeFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sortPopupView: SortPopUpMenuController!
    var datePopupView: DatePopUpMenuController!

    var isSortPopUpVisible = false
    var isDatePopUpVisible = false

    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    var currentPredicate: NSPredicate?
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
    var allGroups: [ExpenseGroup] = []

    let titleLabel: UILabel = {
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 15))
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        title.textColor = .white
            
            
        return title
    }()
    let subTitleLabel: UILabel = {
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 20, width: 140, height: 15))
        subTitle.textAlignment = .center
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subTitle.textColor = .white

        return subTitle
    }()

    
    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            let customTapBar = self.tabBarController as! CustomTabBarController
            customTapBar.showCenterButton()
        }
        
        currentPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", currentYear!, currentMonth!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)

        fetchAllPeriod()
        reloadData(predicate: currentPredicate)
        updateTotalAmountsUI()
        updateTitleLabels(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCurrentDate()
        currentPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", currentYear!, currentMonth!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
        
        setupCustomTitleView()
        setupSearchTextField()
        
        fetchAllPeriod()
        reloadData(predicate: currentPredicate)
        
        updateTotalAmountsUI()
        updateTitleLabels(false)

        setupPopUpViews()
        tableView.tableFooterView = UIView()
    }
    

    //MARK: Fetching Data
    
    private func fetchAllPeriod() {
        
        fetchRequest.sortDescriptors = [ ]
        
        allTimeFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        allTimeFetchResultsController.fetchRequest.predicate = NSPredicate(format: "userId = %@", UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)

        allTimeFetchResultsController.delegate = self
        
        do {
            try allTimeFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }

    }
    
    
    func reloadData(predicate: NSPredicate? = nil, sortBy: String = "") {
        
        switch sortBy {
        case "category":
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "category", ascending: false),
                NSSortDescriptor(key: "date", ascending: false)
            ]
            
            currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)

        case "amount":
            currentPeriodFetchResultsController.fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "amount", ascending: false)
            ]
            
            currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        default:
            

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "dateString", ascending: false),
                NSSortDescriptor(key: "amount", ascending: false)
            ]
            
            currentPeriodFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "dateString", cacheName: nil)
            
        }

        currentPeriodFetchResultsController.fetchRequest.predicate = predicate
        currentPeriodFetchResultsController.delegate = self

        
        do {
            try currentPeriodFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }
        
        updateTotalAmountsUI()
        tableView.reloadData()
    }

    //MARK: - IBActions
    
    @IBAction func accountBarButtonPressed(_ sender: Any) {
        
        let allAccountsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "allAccountsVC") as! AllAccountsViewController
        allAccountsVC.delegate = self
        
        present(allAccountsVC, animated: true, completion: nil)
    }
    
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        dismissKeyboard()
        isSortPopUpVisible ? hideSortPopUpView() : showSortPopUpView()
        isSortPopUpVisible.toggle()

        //hide other view if visible
        if isDatePopUpVisible {
            isDatePopUpVisible ? hideDatePopUpView() : showDatePopUpView()
            isDatePopUpVisible.toggle()
        }
    }
    
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        dismissKeyboard()
        isDatePopUpVisible ? hideDatePopUpView() : showDatePopUpView()
        isDatePopUpVisible.toggle()

        //hide other view if visible
        if isSortPopUpVisible {
            isSortPopUpVisible ? hideSortPopUpView() : showSortPopUpView()
            isSortPopUpVisible.toggle()
        }

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
    
    
    
    //MARK: - SutUp items
    
    private func setupCustomTitleView() {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        
        self.navigationItem.titleView = containerView
    }

    
    private func setupCurrentDate() {
        currentMonth = calendarComponents(Date()).month
        currentWeek = calendarComponents(Date()).weekOfYear
        currentYear = calendarComponents(Date()).year
    }

    private func setupPopUpViews() {

        sortPopupView = SortPopUpMenuController()
        sortPopupView.contentView.layer.cornerRadius = 20
        sortPopupView.delegate = self
        sortPopupView.frame = CGRect(x: 0, y: self.view.frame.height
            + 90, width: self.view.frame.width, height: 200)
                
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        
        datePopupView = DatePopUpMenuController()
        datePopupView.contentView.layer.cornerRadius = 20
        datePopupView.delegate = self
        datePopupView.frame = CGRect(x: 0, y: self.view.frame.height
            + 90, width: self.view.frame.width, height: 280)
        
        if keyWindow != nil {
            keyWindow!.addSubview(sortPopupView)
            keyWindow!.addSubview(datePopupView)
        }
    }

    private func setupSearchTextField() {
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = UIColor.systemGray
        searchTextfield.leftViewMode = .always
        searchTextfield.leftView = imageView
        searchTextfield.delegate = self
        searchTextfield.clearButtonMode = .always
    }

    

    
    //MARK: - Calculate totals
    
    private func updateTotalAmountsUI() {
        
        updateUI(total: calculateAllPeriod(), thisPeriod: calculateThisPeriod())
        splitToSection()
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
    
    
    private func splitToSection() {
        
        if currentPeriodFetchResultsController!.sections != nil {
            var sectionNumber = 0

            allGroups = []
            var tempExpense: Expense!
            
            for section in currentPeriodFetchResultsController!.sections! {

                var sectionTotal = 0.0

                for item in 0..<section.numberOfObjects {
                    let indexPath = IndexPath(row: item, section: sectionNumber)
                    tempExpense = currentPeriodFetchResultsController?.object(at: indexPath) as? Expense

                    sectionTotal += tempExpense.amount
                }

                let expGroup = ExpenseGroup(name: section.name, itemCount: 0, totalValue: sectionTotal, percent: 0.0)
                
                allGroups.append(expGroup)

                sectionNumber += 1
            }
            
        }
    }
    
    //MARK: - Update UI
    private func updateTitleLabels(_ yearOnly: Bool) {
        
        titleLabel.text = UserAccount.currentAccount() != nil ? UserAccount.currentAccount()!.name : "Main Account"

        let year = currentYear != nil ? currentYear! : 0000

        if yearOnly {
            subTitleLabel.text = "\(year)"
        } else {
            let month = currentMonth != nil ? monthNames[currentMonth! - 1] : "___"
            subTitleLabel.text = month + ", " + "\(year)"
        }
        
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
    
    func showDatePopUpView() {
         UIView.animate(withDuration: 0.3) {
            self.datePopupView.frame.origin.y = AnimationManager.screenBounds.maxY - self.datePopupView.frame.height
         }

     }
     
     func hideDatePopUpView() {
         UIView.animate(withDuration: 0.3) {
             self.datePopupView.frame.origin.y = AnimationManager.screenBounds.maxY + 1
         }

     }
    
    private func hidePopUpViews() {
        if isDatePopUpVisible {
            hideDatePopUpView()
            isDatePopUpVisible.toggle()
        }
        
        if isSortPopUpVisible {
            hideSortPopUpView()
            isSortPopUpVisible.toggle()
        }
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
}

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        updateTotalAmountsUI()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        headerView.backgroundColor = UIColor(named: "navigationBackground")
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 30))

        titleLabel.text = allGroups[section].name.capitalizingFirstLetter()
        
        
        let totalLabel = UILabel(frame: CGRect(x: tableView.frame.width - 150, y: 0, width: 140, height: 30))
        
        totalLabel.textAlignment = .right
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.text = "Total: " + convertToCurrency(number: allGroups[section].totalValue).replacingOccurrences(of: ".00", with: "")

        headerView.addSubview(titleLabel)
        headerView.addSubview(totalLabel)
        
        return headerView
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let editVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addItemVC") as! AddExpenseViewController
        editVc.expenseToEdit = currentPeriodFetchResultsController.object(at: indexPath) as? Expense
        
        let customTapBar = self.tabBarController as! CustomTabBarController
        customTapBar.hideCenterButton()
        
        hidePopUpViews()
        
        self.navigationController?.pushViewController(editVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let expenseToDelete = currentPeriodFetchResultsController.object(at: indexPath) as! Expense
                        
            context.delete(expenseToDelete)
            appDelegate.saveContext()
        }
    }
}


extension TransactionsViewController: SortPopupMenuControllerDelegate {
    
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


extension TransactionsViewController: DatePopUpMenuControllerDelegate {
    
    func didSelectDateFromPicker(_ month: Int?, year: Int) {
        
            
        if month != nil {
            currentPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", year, month!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
            currentMonth = month

        } else {
            currentPredicate = NSPredicate(format: "year = %i && userId = %@", year, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
        }
        
        currentYear = year
        
        updateTitleLabels(month == nil)
        reloadData(predicate: currentPredicate)
    }
    
    
    func didSelectDateSegment(_ selectedIndex: Int) {
        
        switch selectedIndex {
        case 0:
            if currentWeek != nil {
                currentPredicate = NSPredicate(format: "weekOfTheYear = %i && userId = %@", currentWeek!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
            }
        case 1:
            
            if currentYear != nil && currentMonth != nil {
                currentPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", currentYear!, currentMonth!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
            }
        default:
            if currentYear != nil {
                currentPredicate = NSPredicate(format: "year = %i && userId = %@", currentYear!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)
            }
        }

        reloadData(predicate: currentPredicate)
    }
    
    func dateBackgroundTapped() {
        hideDatePopUpView()
        isDatePopUpVisible.toggle()
    }
}


extension TransactionsViewController: AllAccountsViewControllerDelegate {
    
    func didSelectAccount() {
        currentPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", currentYear!, currentMonth!, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg)

        fetchAllPeriod()
        reloadData(predicate: currentPredicate)
        updateTotalAmountsUI()
        updateTitleLabels(false)
    }
}


extension TransactionsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hidePopUpViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == searchTextfield {
            
            if textField.text != "" {
                
                let searchPredicate = NSPredicate(format: "nameDescription CONTAINS[cd] %@", textField.text!)
                let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [currentPredicate!, searchPredicate])
                
                reloadData(predicate: combinedPredicate)
            }
            
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        reloadData(predicate: currentPredicate)

        textField.text = ""
        textField.resignFirstResponder()
        return false
    }
}
