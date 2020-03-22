//
//  OverviewViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData
import Charts

class OverviewViewController: UIViewController {

    //MARK: - IBOUtlets
    @IBOutlet weak var expensesChart: PieChartView!
    @IBOutlet weak var expensesTableView: UITableView!
    
    @IBOutlet weak var incomeChart: PieChartView!
    @IBOutlet weak var incomeTableView: UITableView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var moneyOutLabel: UILabel!
    @IBOutlet weak var moneyInLabel: UILabel!

    //MARK: - Vars
    var allExpenses: [Expense] = []
    var allIncomings: [Expense] = []
    
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        incomeTableView.tableFooterView = UIView()
        expensesTableView.tableFooterView = UIView()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        incomeChart.isHidden = true
        expensesChart.isHidden = true
        
        fetchItemsFromCoreData()
        separateExpenses()
    }
    
    private func fetchItemsFromCoreData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "amount", ascending: false) ]

        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            print("error saving house \(error.localizedDescription)")
        }
    }


    func reloadData(predicate: NSPredicate? = nil) {
        
        fetchResultsController.fetchRequest.predicate = predicate

        do {
            try fetchResultsController.performFetch()
            print("loading")
        } catch {
            fatalError("error fetching")
        }
        
        incomeTableView.reloadData()
        expensesTableView.reloadData()

    }
    
    
    //MARK: UpdateUI
    
    func updateUI(incoming: Double, expense: Double) {
        
        let balance = convertToCurrency(number: incoming - expense)
        let incoming = convertToCurrency(number: incoming)
        let expense = convertToCurrency(number: expense)
        
        
        balanceLabel.attributedText = formatStringDecimalSize(balance, mainNumberSize: 30.0, decimalNumberSize: 15.0)
        moneyInLabel.attributedText = formatStringDecimalSize(incoming, mainNumberSize: 20.0, decimalNumberSize: 10.0)
        moneyOutLabel.attributedText = formatStringDecimalSize(expense, mainNumberSize: 20.0, decimalNumberSize: 10.0)
        
        updateChartWithData()
    }
    
    func separateExpenses() {
        
        //reset numbers
        var totalIncoming = 0.0
        var totalExpense = 0.0
        
        allExpenses = []
        allIncomings = []
        
        for expense in fetchResultsController.fetchedObjects! {
            
            let tempExpense = expense as! Expense
            
            if tempExpense.isExpense {
                totalExpense += tempExpense.amount
                if allExpenses.count < 10 {
                    allExpenses.append(tempExpense)
                }
            } else {
                totalIncoming += tempExpense.amount
                if allIncomings.count < 10 {
                    allIncomings.append(tempExpense)
                }
            }
            
        }
        
        incomeTableView.reloadData()
        expensesTableView.reloadData()
        updateUI(incoming: totalIncoming, expense: totalExpense)
    }


    //MARK: Charts
    func updateChartWithData() {

        var incomingDataEntries: [PieChartDataEntry] = []
        var expenseDataEntries: [PieChartDataEntry] = []
        
        
        //incoming chart
        for expense in allIncomings {
            let tempExpense = expense
            let tempEntry = PieChartDataEntry(value: tempExpense.amount, label: "")
            incomingDataEntries.append(tempEntry)
        }
        
        let incomingChartDataSet = PieChartDataSet(values: incomingDataEntries, label: "")
        incomingChartDataSet.colors = ChartColorTemplates.joyful()
        incomingChartDataSet.drawValuesEnabled = false // hides value labels
        
        let incomingChartData = PieChartData(dataSet: incomingChartDataSet)
        
        incomeChart.data = incomingChartData
        incomeChart.chartDescription?.text = ""
        incomeChart.legend.enabled = false // hides bottom legends
        incomeChart.drawEntryLabelsEnabled = false // hides description labels
        incomeChart.holeColor = .clear

        //end of incoming chart

        
        //expense chart
        for expense in allExpenses {
            let tempExpense = expense
            let tempEntry = PieChartDataEntry(value: tempExpense.amount, label: "")
            expenseDataEntries.append(tempEntry)
        }

        let expenseChartDataSet = PieChartDataSet(values: expenseDataEntries, label: "")
        expenseChartDataSet.colors = ChartColorTemplates.joyful()
        expenseChartDataSet.drawValuesEnabled = false // hides value labels
        
        let expenseChartData = PieChartData(dataSet: expenseChartDataSet)
        
        expensesChart.data = expenseChartData
        expensesChart.chartDescription?.text = ""
        expensesChart.legend.enabled = false // hides bottom legends
        expensesChart.drawEntryLabelsEnabled = false // hides description labels
        expensesChart.holeColor = .clear

        //end of expense chart
        
        
        animateChartWithDelay()
    }

    private func animateChartWithDelay() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.incomeChart.isHidden = false
            self.expensesChart.isHidden = false
            
            self.incomeChart.animate(xAxisDuration: 0.5, easingOption: ChartEasingOption.easeOutBack)
            self.expensesChart.animate(xAxisDuration: 0.5, easingOption: ChartEasingOption.easeOutBack)
        })
    }


}


extension OverviewViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        separateExpenses()
    }
}


extension OverviewViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == incomeTableView {

            return allIncomings.count
        }

        return allExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseTableViewCell
        
        var expense: Expense!

        if tableView == incomeTableView {
            expense = allIncomings[indexPath.row]
        } else {
            expense = allExpenses[indexPath.row]
        }
        
        cell.setupCellWith(expense, backgroundColor: ColorFromChart(indexPath.row))
        
        return cell
    }
    


}
