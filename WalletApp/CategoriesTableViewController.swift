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
    
    var currentIncomingCategories: [String] = []
    var currentOutgoingCategories: [String] = []
    
    
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
        
        if categorySegment.selectedSegmentIndex == 0 {
            name = ExpenseCategories.array[indexPath.row].rawValue
        } else {
            name = IncomeCategories.array[indexPath.row].rawValue
        }
        
        cell.generateCell(categoryName: name)
        return cell
    }
    
    
    //MARK: IBActions
    
    @IBAction func categorySegmentValueChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    //MARK: SaveChages
    
    private func saveChanges() {
        
    }
    
    //MARK: LoadUserDefaults
    
    private func loadUserDefaults() {
//        let nameArray = ["Ramu","JAGAN","Steve","Swift"]
//        let namesArrayData = NSKeyedArchiver.archivedData(withRootObject: nameArray)
//        UserDefaults.standard.set(namesArrayData, forKey: "arrayData")
//
//        let retriveArrayData = userDefaults.object(forKey:  "arrayData") as? NSData
//
//        if let retriveArrayData = namesArrayData {
//            let retriveArray = NSKeyedUnarchiver.unarchiveObject(with: namesArraydata as Data) as? [nameArray]
//        }
        
    }



}
