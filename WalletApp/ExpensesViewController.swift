//
//  ExpensesViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ExpensesViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dailyAverageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expensesChart: PieChartView!
    
    //MARK: - Vars
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentPredicate: NSPredicate?

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")

    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    var allGroups: [ExpenseGroup] = []

    
    //MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()

        setupCurrentDate()
        reloadData(predicate: NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i && userId = %@", currentYear!, currentMonth!, true, UserAccount.currentAccount()?.id?.uuidString ?? ""))
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupCurrentDate()
//        reloadData(predicate: NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i", currentYear!, currentMonth!, true))
        
    }
    

    func reloadData(predicate: NSPredicate? = nil) {
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: false),
                                        NSSortDescriptor(key: "amount", ascending: false)
                                        ]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)

        
        fetchResultsController!.delegate = self

        
        fetchResultsController!.fetchRequest.predicate = predicate

        do {
            try fetchResultsController!.performFetch()
        } catch {
            fatalError("income fetch error")
        }
        
        splitToSection()
        calculateAmounts()
        tableView.reloadData()
    }

    
    //MARK: UpdateUI
    
    func updateUI(total: Double, daily: Double) {
        
        let total = convertToCurrency(number: total)
        let daily = convertToCurrency(number: daily)
        
        
        totalLabel.attributedText = formatStringDecimalSize(total, mainNumberSize: 30.0, decimalNumberSize: 15.0)
        dailyAverageLabel.attributedText = formatStringDecimalSize(daily, mainNumberSize: 20.0, decimalNumberSize: 10.0)
    }
    

    func calculateAmounts() {
        
        var total = 0.0
        var dailyAverage = 0.0
        
        for expense in fetchResultsController!.fetchedObjects! {
            let tempExpense = expense as! Expense
            total += tempExpense.amount
        }
        
        dailyAverage = total / 30
        
        updateUI(total: total, daily: dailyAverage)
    }
    
    //MARK: Charts
    func updateChartWithData() {
        
        var dataEntries: [PieChartDataEntry] = []
        
        for expense in fetchResultsController!.fetchedObjects! {
            let tempExpense = expense as! Expense
            
            let tempEntry = PieChartDataEntry(value: tempExpense.amount, label: "")
            
            dataEntries.append(tempEntry)
        }
        
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.joyful()
        chartDataSet.drawValuesEnabled = false // hides value labels
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        expensesChart.data = chartData
        expensesChart.chartDescription?.text = ""
        expensesChart.legend.enabled = false // hides bottom legends
        expensesChart.drawEntryLabelsEnabled = false // hides description labels
        expensesChart.holeColor = .clear
        
        animateChartWithDelay()
    }

    func animateChartWithDelay() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.expensesChart.isHidden = false
            self.expensesChart.animate(xAxisDuration: 0.5, easingOption: ChartEasingOption.easeOutBack)
        })
    }

    //MARK: - Setup

    private func setupCurrentDate() {
        currentMonth = calendarComponents(Date()).month
        currentWeek = calendarComponents(Date()).weekOfYear
        currentYear = calendarComponents(Date()).year
    }
    
    //MARK: - Helpers
    private func splitToSection() {
        
        if fetchResultsController!.sections != nil {
            var sectionNumber = 0
            allGroups = []
            
            for section in fetchResultsController!.sections! {
                var sectionTotal = 0.0

                for item in 0..<section.numberOfObjects {
                    
                    let indexPath = IndexPath(row: item, section: sectionNumber)
                    sectionTotal += (fetchResultsController?.object(at: indexPath) as! Expense).amount
                }

                allGroups.append(ExpenseGroup(name: section.name, itemCount: section.numberOfObjects, totalValue: sectionTotal))

                sectionNumber += 1
            }
        }
    }

}

extension ExpensesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        calculateAmounts()
        updateChartWithData()
        animateChartWithDelay()
        tableView.reloadData()
    }
}


extension ExpensesViewController: UITableViewDataSource {
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseGroupTableViewCell

        let expenseGroup = allGroups[indexPath.row] 

        cell.setupCellWith(expenseGroup, backgroundColor: ColorFromChart(indexPath.row))

        return cell
    }

}

extension ExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let categoryVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailVC") as! CategoryDetailTableViewController
        
        categoryVc.selectedCategoryName = allGroups[indexPath.row].name
        
        let customTapBar = self.tabBarController as! CustomTabBarController
        customTapBar.hideCenterButton()
        
        self.navigationController?.pushViewController(categoryVc, animated: true)

    }
}
