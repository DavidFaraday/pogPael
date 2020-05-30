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
    @IBOutlet weak var accountTotalView: UIView!
    @IBOutlet weak var accountBackgroundView: UIView!
    @IBOutlet weak var accountTopBackground: UIView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var incomesLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var pageController: UIPageControl!
    
    //Category card
    @IBOutlet weak var categoryDetailView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTopBackground: UIView!
    
    
    //MARK: - Vars
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var account: Account?
    var allGroups: [ExpenseGroup] = []

    var showExpense = true
    var showingAccount = true

    var totalIncome: Double!
    var totalExpense: Double!

    //MARK: - ViewLifecycle
    
    override func viewDidLayoutSubviews() {

        positionCardViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            let customTapBar = self.tabBarController as! CustomTabBarController
            customTapBar.showCenterButton()
        }
        showCurrentAccountDetails()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        showCurrentAccountDetails()
        setupSwipes()
        setupUI()
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
    
    @IBAction func switchCategoryTypeButtonPressed(_ sender: Any) {
        showExpense.toggle()
        splitToSection(forExpense: showExpense)
        updateCategoryLabel()
        tableView.reloadData()

    }
    
    
    @IBAction func pageControllerTap(_ sender: UIPageControl) {
        
        switch sender.currentPage {
        case 0:
            showingAccount = true
            animateViewIn()
        case 1:
            showingAccount = false
            animateViewIn()
        default:
            return
        }
    }
    
    @objc func swipeDetected(_ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .left:
            showingAccount = false
            animateViewIn()
        case .right:
            showingAccount = true
            animateViewIn()
        default:
            return
        }

    }

    //MARK: - SetupUI
    private func setupUI() {
        
        accountBackgroundView.layer.cornerRadius = 10
        
        self.accountTopBackground.applyGradient(colors: [
            UIColor(named: "gradientStartColor")!.cgColor,
            UIColor(named: "gradientEndColor")!.cgColor],
                                         locations: [0.0, 1.0],
                                         direction: .leftToRight, cornerRadius: 10)
        
        accountTopBackground.layer.cornerRadius = 10
        accountTopBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        categoryDetailView.layer.cornerRadius = 10

        categoryTopBackground.layer.cornerRadius = 10
        categoryTopBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
                self.categoryTopBackground.applyGradient(colors: [
                    UIColor(named: "gradientStartColor")!.cgColor,
                    UIColor(named: "gradientEndColor")!.cgColor],
                                                 locations: [0.0, 1.0],
                                                 direction: .leftToRight, cornerRadius: 10)

    }
    
    private func positionCardViews() {
        
        if self.showingAccount {
            self.accountTotalView.frame.origin.x = AnimationManager.screenBounds.minX + 16
            self.categoryDetailView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
            self.pageController.currentPage = 0
        } else {
            
            self.categoryDetailView.frame.origin.x = AnimationManager.screenBounds.minX + 16
            self.accountTotalView.frame.origin.x = AnimationManager.screenBounds.minX - (self.accountTotalView.frame.width + 10)
            self.pageController.currentPage = 1

        }
        
    }
    
    
    //MARK: - Animations

    func animateViewIn() {

        UIView.animate(withDuration: 0.5) {
            self.positionCardViews()
        }
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
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "category", ascending: false),
                                             NSSortDescriptor(key: "amount", ascending: false)
                                            ]

            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: "category", cacheName: nil)
            fetchResultsController.delegate = self
            
            fetchResultsController.fetchRequest.predicate = NSPredicate(format: "userId == %@", account!.id! as CVarArg)

            do {
                try fetchResultsController.performFetch()
            } catch {
                fatalError("error fetching")
            }
            
            separateExpenses()
            splitToSection(forExpense: showExpense)
            tableView.reloadData()
        }

    }
    
    //MARK: - Helpers
    private func separateExpenses() {
        self.totalIncome = 0.0
        self.totalExpense = 0.0
        
        for expense in fetchResultsController.fetchedObjects! {
            
            let tempExpense = expense as! Expense
            
            if tempExpense.isExpense {
                totalExpense += tempExpense.amount
            } else {
                totalIncome += tempExpense.amount
            }
            
        }

        updateTotalLabels()
    }
    
    private func splitToSection(forExpense: Bool) {
        
        if fetchResultsController!.sections != nil {
            var sectionNumber = 0
            
            allGroups = []
            var tempExpense: Expense!
            
            for section in fetchResultsController!.sections! {

                var sectionTotal = 0.0
                var numberOfItems = 0

                for item in 0..<section.numberOfObjects {
                    let indexPath = IndexPath(row: item, section: sectionNumber)
                    tempExpense = fetchResultsController?.object(at: indexPath) as? Expense

                    if tempExpense.isExpense == forExpense {
                        numberOfItems += 1
                        sectionTotal += tempExpense.amount
                    }
                }

                let expGroup = ExpenseGroup(name: section.name, itemCount: numberOfItems, totalValue: sectionTotal, percent: percentFromTotal(sectionTotal, isExpense: forExpense))
                

                if expGroup.itemCount > 0 {
                    allGroups.append(expGroup)
                }

                sectionNumber += 1
            }
            
            allGroups = allGroups.sorted(by: { $0.totalValue > $1.totalValue })

        }
    }

    
    private func showCurrentAccountDetails() {
        account = UserAccount.currentAccount()

        loadAccountDetails()
        loadExpenses()
    }
    
    private func setupSwipes() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(_:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        accountBackgroundView.addGestureRecognizer(leftSwipe)
        categoryDetailView.addGestureRecognizer(rightSwipe)
        categoryDetailView.isUserInteractionEnabled = true
        accountBackgroundView.isUserInteractionEnabled = true
    }
    
    private func percentFromTotal(_ amount: Double, isExpense: Bool) -> Double {

        guard let tempTotal = isExpense ? totalExpense : totalIncome else { return 0.0 }
        return (amount * 100) / tempTotal
    }

    
    //MARK: - UpdateUI

    func updateTotalLabels() {
        
        let balance = convertToCurrency(number: totalIncome - totalExpense)
        let incoming = convertToCurrency(number: totalIncome)
        let expense = convertToCurrency(number: totalExpense)
        
        let total = NSMutableAttributedString()
        total.append(NSAttributedString(string: "Total Balance = "))
        total.append(formatStringDecimalSize(balance, mainNumberSize: 15.0, decimalNumberSize: 10.0))

        
        totalLabel.attributedText = total
        incomesLabel.attributedText = formatStringDecimalSize(incoming, mainNumberSize: 18.0, decimalNumberSize: 10.0)
        expensesLabel.attributedText = formatStringDecimalSize(expense, mainNumberSize: 18.0, decimalNumberSize: 10.0)
    }
    
    private func updateCategoryLabel() {
        categoryNameLabel.text = showExpense ? "Top Expense Categories" : "Top Income Categories"
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
        splitToSection(forExpense: showExpense)
        tableView.reloadData()

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


extension AccountsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allGroups.count < 6 ? allGroups.count : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseGroupTableViewCell

        let expenseGroup = allGroups[indexPath.row]

        cell.setupCellWith(expenseGroup, backgroundColor: ColorFromChart(indexPath.row))

        return cell
    }
}


extension AccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let categoryVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailVC") as! CategoryDetailTableViewController
        
        categoryVc.selectedCategoryName = allGroups[indexPath.row].name
        categoryVc.forAllPeriod = true
        categoryVc.forExpense = showExpense
            
        self.navigationController?.pushViewController(categoryVc, animated: true)

    }
}
