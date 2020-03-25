//
//  DashboardViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

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
    
    var datePopupView: DatePopUpMenuController!
    var isDatePopUpVisible = false

    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?

    var currentView = 0
    var lineView = UIView()
    
    //MARK: ViewLifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideViews(view: 0)
        animateViewIn(view: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
        self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
        
        setupPopUpViews()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupCenterButton()
        setupCurrentDate()
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
            + 1, width: self.view.frame.width, height: 280)
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.addSubview(datePopupView)
    }

    private func updateData(_ month: Int?, year: Int) {
        
        
        var overviewPredicate: NSPredicate!
        var expensePredicate: NSPredicate!
        var incomePredicate: NSPredicate!

        if month != nil {
            overviewPredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i", year, month!)
            expensePredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i", year, month!, true)
            
            incomePredicate = NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i", year, month!, false)

        } else {
            overviewPredicate = NSPredicate(format: "year = %i ", year)
            expensePredicate = NSPredicate(format: "year = %i && isExpense == %i", year, true)
            incomePredicate = NSPredicate(format: "year = %i && isExpense == %i", year, false)
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

                overviewPredicate = NSPredicate(format: "weekOfTheYear = %i", currentWeek!)
                expensePredicate = NSPredicate(format: "weekOfTheYear = %i && isExpense == %i", currentWeek!, true)
                incomePredicate = NSPredicate(format: "weekOfTheYear = %i && isExpense == %i", currentWeek!, false)

            }
        case 1:
            
            if currentYear != nil && currentMonth != nil {

                overviewPredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i", currentYear!, currentMonth!)
                expensePredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i && isExpense == %i", currentYear!, currentMonth!, true)
                incomePredicate = NSPredicate(format: "year = %i && monthOfTheYear == %i && isExpense == %i", currentYear!, currentMonth!, false)
            }
            
        default:
            
            if currentYear != nil {

                overviewPredicate = NSPredicate(format: "year = %i ", currentYear!)
                expensePredicate = NSPredicate(format: "year = %i && isExpense == %i", currentYear!, true)
                incomePredicate = NSPredicate(format: "year = %i && isExpense == %i", currentYear!, false)
            }
        }
        
        
//        overviewViewController?.currentPredicate = overviewPredicate
        overviewViewController?.reloadData(predicate: overviewPredicate)
        overviewViewController?.updateChartWithData()
        
        expenseViewController?.reloadData(predicate: expensePredicate)
        expenseViewController?.updateChartWithData()
        
        incomingViewController?.reloadData(predicate: incomePredicate)
        incomingViewController?.updateChartWithData()
    }


    //MARK: CustomMiddleButton
    
//    func setupCenterButton() {
//        let centerButton = UIButton(frame: CGRect(x: 0, y: 10, width: 45, height: 45))
//
//        var centerButtonFrame = centerButton.frame
//        centerButtonFrame.origin.y = (view.bounds.height - centerButtonFrame.height) - 2
//        centerButtonFrame.origin.x = view.bounds.width/2 - centerButtonFrame.size.width/2
//        centerButton.frame = centerButtonFrame
//
//        centerButton.layer.cornerRadius = 35
//        tabBarController?.tabBar.addSubview(centerButton)
//
//        centerButton.setBackgroundImage(#imageLiteral(resourceName: "general"), for: .normal)
//        centerButton.addTarget(self, action: #selector(centerButtonAction(sender:)), for: .touchUpInside)
//
//        view.layoutIfNeeded()
//    }

    

    // MARK: - Centre button Actions
    
//    @objc private func centerButtonAction(sender: UIButton) {
//        self.tabBarController?.selectedIndex = 2
//    }
    
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

}


extension DashboardViewController: DatePopUpMenuControllerDelegate {
    
    func didSelectDateFromPicker(_ month: Int?, year: Int) {
        
        updateData(month, year: year)
    }
    
    
    func didSelectDateSegment(_ selectedIndex: Int) {
        
        updateDataFromSegment(selectedIndex)

    }
    
    func dateBackgroundTapped() {
        hideDatePopUpView()
        isDatePopUpVisible.toggle()
    }
}

