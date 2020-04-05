//
//  DashboardViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var incomesView: UIView!
    
    @IBOutlet weak var overviewButtonOutlet: UIButton!
    @IBOutlet weak var expenseButtonOutlet: UIButton!
    @IBOutlet weak var incomeButtonOutlet: UIButton!
    @IBOutlet weak var buttonHolderView: UIView!
    
    //MARK: - Vars
    var overviewViewController: OverviewViewController? = nil
    var expenseViewController: ExpensesViewController? = nil
    var incomingViewController: IncomingsViewController? = nil
    
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
    
    
    
    var datePopupView: DatePopUpMenuController!
    var isDatePopUpVisible = false

    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?

    var currentView = 0
    var lineView = UIView()
    
    var firstRun: Bool?

    
    //MARK: ViewLifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstRunCheck()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.150) {
            let customTapBar = self.tabBarController as! CustomTabBarController
            customTapBar.showCenterButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hideViews(view: 0)
            self.animateViewIn(view: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
        self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
        
        setupPopUpViews()
        setupCurrentDate()
        setupCustomTitleView()
        updateTitleLabels(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLineView()
    }

    
    //MARK: IBActions
    
    @IBAction func calendarBarButtonPressed(_ sender: Any) {
        isDatePopUpVisible ? hideDatePopUpView() : showDatePopUpView()
        isDatePopUpVisible.toggle()
        
    }
    
    @IBAction func overviewButtonPressed(_ sender: Any) {
        hideViews(view: 0)
        animateViewIn(view: 0)
    }
    
    @IBAction func expenseButtonPressed(_ sender: Any) {
        hideViews(view: 1)
        animateViewIn(view: 1)
    }
    
    @IBAction func incomeButtonPressed(_ sender: Any) {
        hideViews(view: 2)
        animateViewIn(view: 2)
    }
    
    
    
    //MARK: Animations
    func animateViewIn(view: Int) {
        
        hideCharts()

        UIView.animate(withDuration: 0.7) {
            switch view {
            case 0:

                self.overviewViewController?.updateChartWithData()

                self.lineView.frame.origin.x = self.overviewButtonOutlet.frame.origin.x

                self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX
                if self.currentView == 2 {
                    self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                } else if self.currentView == 1 {
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                }
                
            case 1:
                self.expenseViewController?.updateChartWithData()

                self.lineView.frame.origin.x = self.expenseButtonOutlet.frame.origin.x

                
                if self.currentView == 0 {
                    //come from right
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX
                    self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX - (self.overviewView.frame.width + 10)
                    
                } else if self.currentView == 2 {
                    //come from left
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX
                    self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                }
                
            case 2:
                self.lineView.frame.origin.x = self.incomeButtonOutlet.frame.origin.x

                self.incomesView.frame.origin.x = AnimationManager.screenBounds.minX
                self.incomingViewController?.updateChartWithData()
                
                if self.currentView == 0 {
                    self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX - (self.overviewView.frame.width + 10)
                    
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX - (self.expensesView.frame.width + 10)
                    
                } else if self.currentView == 1 {
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX - (self.expensesView.frame.width + 10)
                }
            default:
                return
            }
            
            self.currentView = view
        }
        
    }
    
    
    func hideViews(view: Int) {
        //so that the expense view is not visible when we switch sides
        switch view {
        case 0:
            if self.currentView == 2 {
                expensesView.isHidden = true
            }
        case 1:
            expensesView.isHidden = false
        case 2:
            if self.currentView == 0 {
                expensesView.isHidden = true
            }
        default:
            return
        }
    }
    
    func hideCharts() {
        //hide charts with delay so that we unhide them to show with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.overviewViewController?.incomeChart.isHidden = true
            self.overviewViewController?.expensesChart.isHidden = true
            self.expenseViewController?.expensesChart.isHidden = true
            self.incomingViewController?.incomingChart.isHidden = true
        })
    }
    
    
    //MARK: Setup Views and Data
    private func setupLineView() {
        
        lineView = UIView(frame: CGRect(x: 0, y: buttonHolderView.frame.height-1, width: incomeButtonOutlet.frame.width, height: 1))
        lineView.backgroundColor = UIColor.lightGray
        
        buttonHolderView.addSubview(lineView)
    }
    

    private func setupPopUpViews() {
        
        datePopupView = DatePopUpMenuController()
        datePopupView.contentView.layer.cornerRadius = 20
        datePopupView.delegate = self
        datePopupView.frame = CGRect(x: 0, y: self.view.frame.height
            + 90, width: self.view.frame.width, height: 280)
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.addSubview(datePopupView)
    }

    private func updateData(_ month: Int?, year: Int) {
        
        
        var overviewPredicate: NSPredicate!
        var expensePredicate: NSPredicate!
        var incomePredicate: NSPredicate!

        if month != nil {
            overviewPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && userId = %@", year, month!, UserAccount.currentAccount()?.id?.uuidString ?? "")
            expensePredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i && userId = %@", year, month!, true, UserAccount.currentAccount()?.id?.uuidString ?? "")
            
            incomePredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i && userId = %@", year, month!, false, UserAccount.currentAccount()?.id?.uuidString ?? "")

        } else {
            overviewPredicate = NSPredicate(format: "year = %i && userId = %@", year, UserAccount.currentAccount()?.id?.uuidString ?? "")
            expensePredicate = NSPredicate(format: "year = %i && isExpense == %i && userId = %@", year, true, UserAccount.currentAccount()?.id?.uuidString ?? "")
            incomePredicate = NSPredicate(format: "year = %i && isExpense == %i && userId = %@", year, false, UserAccount.currentAccount()?.id?.uuidString ?? "")
        }
        
        overviewViewController?.reloadData(predicate: overviewPredicate)
        overviewViewController?.updateChartWithData()

        expenseViewController?.reloadData(predicate: expensePredicate)
        expenseViewController?.updateChartWithData()
        
        incomingViewController?.reloadData(predicate: incomePredicate)
        incomingViewController?.updateChartWithData()
    }
    
    private func updateDataFromSegment(_ segmentValue: Int) {
        
        
        var overviewPredicate: NSPredicate!
        var expensePredicate: NSPredicate!
        var incomePredicate: NSPredicate!

        switch segmentValue {
        case 0:
            
            if currentWeek != nil {
                
                overviewPredicate = NSPredicate(format: "weekOfTheYear = %i && userId = %@", currentWeek!, UserAccount.currentAccount()?.id?.uuidString ?? "")
                expensePredicate = NSPredicate(format: "weekOfTheYear = %i && isExpense == %i && userId = %@", currentWeek!, true, UserAccount.currentAccount()?.id?.uuidString ?? "")
                incomePredicate = NSPredicate(format: "weekOfTheYear = %i && isExpense == %i && userId = %@", currentWeek!, false, UserAccount.currentAccount()?.id?.uuidString ?? "")

            }
        case 1:
            
            if currentYear != nil && currentMonth != nil {

                overviewPredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i && userId = %@", currentYear!, currentMonth!, UserAccount.currentAccount()?.id?.uuidString ?? "")
                expensePredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i && isExpense == %i && userId = %@", currentYear!, currentMonth!, true, UserAccount.currentAccount()?.id?.uuidString ?? "")
                incomePredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i && isExpense == %i && userId = %@", currentYear!, currentMonth!, false, UserAccount.currentAccount()?.id?.uuidString ?? "")
            }
            
        default:
            
            if currentYear != nil {

                overviewPredicate = NSPredicate(format: "year = %i && userId = %@", currentYear!, UserAccount.currentAccount()?.id?.uuidString ?? "")
                expensePredicate = NSPredicate(format: "year = %i && isExpense == %i && userId = %@", currentYear!, true, UserAccount.currentAccount()?.id?.uuidString ?? "")
                incomePredicate = NSPredicate(format: "year = %i && isExpense == %i && userId = %@", currentYear!, false, UserAccount.currentAccount()?.id?.uuidString ?? "")
            }
        }
        
        
        overviewViewController?.reloadData(predicate: overviewPredicate)
        overviewViewController?.updateChartWithData()
        
        expenseViewController?.reloadData(predicate: expensePredicate)
        expenseViewController?.updateChartWithData()
        
        incomingViewController?.reloadData(predicate: incomePredicate)
        incomingViewController?.updateChartWithData()
        
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

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "overviewSegue":
            self.overviewViewController = segue.destination as? OverviewViewController
        case "expenseSegue":
            self.expenseViewController = segue.destination as? ExpensesViewController
        case "incomingSegue":
            self.incomingViewController = segue.destination as? IncomingsViewController

        default:
            break
        }
    }

    //MARK: - Setup

    private func setupCurrentDate() {
        currentMonth = calendarComponents(Date()).month
        currentWeek = calendarComponents(Date()).weekOfYear
        currentYear = calendarComponents(Date()).year
    }
    
    private func setupCustomTitleView() {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        
        self.navigationItem.titleView = containerView
    }
    
    //MARK: - UpdateUI
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

    
    //MARK: - FirstRunCheck
    private func firstRunCheck() {
        
        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstRun! {
            
            createAccount()
            
            let rawArrayOfExpenses = ExpenseCategories.array.map { $0.rawValue }
            let rawArrayOfIncomes = IncomeCategories.array.map { $0.rawValue }

            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(rawArrayOfExpenses, forKey: kEXPENSECATEGORIES)
            userDefaults.set(rawArrayOfIncomes, forKey: kINCOMECATEGORIES)

            userDefaults.synchronize()
        }
    }

    private func createAccount() {
        
        UserAccount.createAccount(name: "Main Account", image: nil)
    }
}


extension DashboardViewController: DatePopUpMenuControllerDelegate {
    
    func didSelectDateFromPicker(_ month: Int?, year: Int) {
        
        updateData(month, year: year)
        
        if month != nil {
            currentMonth = month
        }
        
        currentYear = year
        updateTitleLabels(month == nil)
    }
    
    
    func didSelectDateSegment(_ selectedIndex: Int) {
        
        updateDataFromSegment(selectedIndex)
        updateTitleLabels(selectedIndex == 2)
    }
    
    func dateBackgroundTapped() {
        hideDatePopUpView()
        isDatePopUpVisible.toggle()
    }
}

