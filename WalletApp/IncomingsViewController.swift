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
    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()
        
        setupCurrentDate()
        reloadData(predicate: NSPredicate(format: "year = %i && monthOfTheYear = %i && isExpense == %i && userId = %@", currentYear!, currentMonth!, false, UserAccount.currentAccount()?.id?.uuidString ?? ""))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    
    func reloadData(predicate: NSPredicate? = nil) {
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "amount", ascending: false) ]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController!.delegate = self
        
        fetchResultsController!.fetchRequest.predicate = predicate
        fetchResultsController!.fetchRequest.fetchLimit = 10

        do {
            try fetchResultsController!.performFetch()
        } catch {
            fatalError("income fetch error")
        }
        
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

        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
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
        
        return fetchResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseTableViewCell

        let expense = fetchResultsController?.object(at: indexPath) as! Expense
        
        cell.setupCellWith(expense, backgroundColor: ColorFromChart(indexPath.row), dateFormatShort: false)

        
        return cell
    }
}

extension IncomingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
