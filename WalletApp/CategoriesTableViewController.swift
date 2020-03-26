//
//  CategoriesTableViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 31/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    var currentIncomeCategories: [String] = []
    var currentExpenseCategories: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        loadUserDefaults()
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if categorySegment.selectedSegmentIndex == 0 {
            return ExpenseCategories.array.count
        }
        return IncomeCategories.array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryTableViewCell

        var name = ""
        var isChecked = false
        
        if categorySegment.selectedSegmentIndex == 0 {
            name = ExpenseCategories.array[indexPath.row].rawValue
            isChecked = currentExpenseCategories.contains(name)

        } else {
            name = IncomeCategories.array[indexPath.row].rawValue
            isChecked = currentIncomeCategories.contains(name)
        }
        
        
        cell.generateCell(categoryName: name, isChecked: isChecked)
        return cell
    }
    
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateCellCheck(indexPath)
        tableView.reloadData()
    }

    
    //MARK: IBActions
    @IBAction func categorySegmentValueChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    //MARK: SaveChanges
    
    private func saveChanges() {
        userDefaults.set(currentExpenseCategories, forKey: kEXPENSECATEGORIES)
        userDefaults.set(currentIncomeCategories, forKey: kINCOMECATEGORIES)
        userDefaults.synchronize()
    }
    
    //MARK: LoadUserDefaults
    
    private func loadUserDefaults() {
        
        currentIncomeCategories = userDefaults.object(forKey: kINCOMECATEGORIES) as! [String]
        currentExpenseCategories = userDefaults.object(forKey: kEXPENSECATEGORIES) as! [String]
    }

    //MARK: - Helpers
    
    private func updateCellCheck(_ indexPath: IndexPath) {
        
        if categorySegment.selectedSegmentIndex == 0 {
            
            if currentExpenseCategories.contains(ExpenseCategories.array[indexPath.row].rawValue) {
                //remove

                let indexOfItem = currentExpenseCategories.index(of: ExpenseCategories.array[indexPath.row].rawValue)
                
                if indexOfItem != nil {
                    currentExpenseCategories.remove(at: indexOfItem!)
                }
                
            } else {
                //add

                currentExpenseCategories.append(ExpenseCategories.array[indexPath.row].rawValue)
            }
            
        } else {
            
            if currentIncomeCategories.contains(IncomeCategories.array[indexPath.row].rawValue) {
                //remove
                let indexOfItem = currentIncomeCategories.index(of: IncomeCategories.array[indexPath.row].rawValue)
                
                if indexOfItem != nil {
                    currentIncomeCategories.remove(at: indexOfItem!)
                }
            } else {
                //add
                currentIncomeCategories.append(IncomeCategories.array[indexPath.row].rawValue)
            }

        }
        
        saveChanges()
    }

}


