//
//  IncomingsViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData
import Charts

class IncomingsViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dailyAverageLabel: UILabel!
    @IBOutlet weak var incomingChart: PieChartView!
    
    
    //MARK: Vars
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentPredicate: NSPredicate?

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")

    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    var allGroups: [ExpenseGroup] = []
    var totalIncome = 0.0

    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()
        
        setupCurrentDate()
        reloadData(predicate: NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i && userId = %@", currentYear!, currentMonth!, false, UserAccount.currentAccount()?.id as CVarArg? ?? UUID() as CVarArg))
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()


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
        
        calculateAmounts()
        splitToSection()
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
        
        totalIncome = 0.0
        var dailyAverage = 0.0
        
        for expense in fetchResultsController!.fetchedObjects! {
            let tempExpense = expense as! Expense
            totalIncome += tempExpense.amount
        }
        
        dailyAverage = totalIncome / 30
        
        updateUI(total: totalIncome, daily: dailyAverage)
    }

    //MARK: Charts
    func updateChartWithData() {
        
        var dataEntries: [PieChartDataEntry] = []
        
        for groupExpense in allGroups {
                        
            let tempEntry = PieChartDataEntry(value: groupExpense.totalValue, label: "")
            
            dataEntries.append(tempEntry)
        }

        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.joyful()
        chartDataSet.drawValuesEnabled = false // hides value labels

        let chartData = PieChartData(dataSet: chartDataSet)
        
        incomingChart.data = chartData
        incomingChart.chartDescription?.text = ""
        incomingChart.legend.enabled = false // hides bottom legends
        incomingChart.drawEntryLabelsEnabled = false // hides description labels
        incomingChart.holeColor = .clear

        animateChartWithDelay()
    }
    
    func animateChartWithDelay() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.incomingChart.isHidden = false
            self.incomingChart.animate(xAxisDuration: 0.5, easingOption: ChartEasingOption.easeOutBack)

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

                allGroups.append(ExpenseGroup(name: section.name, itemCount: section.numberOfObjects, totalValue: sectionTotal, percent: percentFromTotal(sectionTotal)))

                sectionNumber += 1
            }
        }
    }
    
    private func percentFromTotal(_ amount: Double) -> Double {

        return (amount * 100) / totalIncome
    }


}

extension IncomingsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        calculateAmounts()
        updateChartWithData()
        animateChartWithDelay()
        tableView.reloadData()
    }
}

extension IncomingsViewController: UITableViewDataSource {
        
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

extension IncomingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let categoryVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categoryDetailVC") as! CategoryDetailTableViewController
        
        categoryVc.selectedCategoryName = allGroups[indexPath.row].name
        categoryVc.forExpense = false

        let customTapBar = self.tabBarController as! CustomTabBarController
        customTapBar.hideCenterButton()
        
        self.navigationController?.pushViewController(categoryVc, animated: true)

    }
}
