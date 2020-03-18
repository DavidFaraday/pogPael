//
//  AddExpenseViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 27/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData


class AddExpenseViewController: UIViewController {
    
    //MARK: Containers

    @IBOutlet weak var nameViewContainer: UIView!
    @IBOutlet weak var categoryViewContainer: UIView!
    
    
    //MARK: Outlets

    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topViewContainer: UIView!
    
    @IBOutlet weak var categoryBackgroundView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    
    //MARK: Calss Vars
    var amount: Double = 0.0
    var amountText = ""
    var category = "general"
    
    var isDisplayingCategory = true
    
    //MARK: ViewLifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.nameViewContainer.frame.origin.y = topViewContainer.frame.maxY + 1
        self.categoryViewContainer.frame.origin.y = topViewContainer.frame.maxY + 1
    }
    
    override func viewDidLayoutSubviews() {
        if isDisplayingCategory {
            self.categoryViewContainer.frame.origin.y = topViewContainer.frame.maxY + 1
        } else {
            self.nameViewContainer.frame.origin.y = topViewContainer.frame.maxY + 1
            self.categoryViewContainer.frame.origin.y = AnimationManager.screenBounds.maxY + 1

        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        createKeyboardButtons()
        updateLabel()
    }



    //MARK: IBActions
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        
        isDisplayingCategory = !isDisplayingCategory
        
        
        if sender.title == "Next" {
            showNameView()
        } else {
            saveExpense()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func categorySegmentValueChanged(_ sender: Any) {
        collectionView.reloadData()
    }
    
    @IBAction func imageTaped(_ sender: UITapGestureRecognizer) {
        
        if !isDisplayingCategory {
            showCategoryView()
        }
        isDisplayingCategory = true
    }
    
    
    
    //MARK: UpdateUI
    private func setupUI() {
        categoryBackgroundView.layer.cornerRadius = categoryBackgroundView.frame.width / 2
    }

    func updateLabel() {
        amountLabel.attributedText = formatStringDecimalSize(convertToCurrency(number: amount), mainNumberSize: 30.0, decimalNumberSize: 15.0)
    }
    
    
    private func showCategoryView() {
        
        self.title = ""
        self.navigationItem.rightBarButtonItem?.title = "Next"
        categorySegment.isHidden = false
        animateCategoryViewIn()
    }

    private func showNameView() {
        
        self.title = "Add Item"
        self.navigationItem.rightBarButtonItem?.title = "Done"
        categorySegment.isHidden = true

        animateCategoryViewOut()
    }

    //MARK: Animation
    func animateCategoryImage(imageName: String) {
        let categoryImage = UIImage(named: imageName)
        
        categoryBackgroundView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.categoryImageView.image = categoryImage
            self.categoryBackgroundView.transform = CGAffineTransform.identity
        }, completion: nil)

    }
    
    private func animateCategoryViewOut() {
        
        UIView.animate(withDuration: 0.3) {
            self.categoryViewContainer.frame.origin.y = AnimationManager.screenBounds.maxY + 1
        }
    }
    
    private func animateCategoryViewIn() {
        
        UIView.animate(withDuration: 0.3) {
            self.categoryViewContainer.frame.origin.y = self.topViewContainer.frame.maxY + 1
        }
    }

    //MARK: Saving Item
    
    private func saveExpense() {
        
        if nameTextField.text != "" && amount != 0.0 {
            let context = AppDelegate.context
            let expense = Expense(context: context)
            expense.amount = amount
            expense.category = category
            expense.isExpense = (categorySegment.selectedSegmentIndex == 0)
            expense.nameDescription = nameTextField.text
            expense.date = Date() // to be changed later
            expense.shouldRepeat = false //to be changed later
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } else {
            print("no name or amount")
        }
        
    }
    

    
}

//for choose categoary
extension AddExpenseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    //MARK: CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if categorySegment.selectedSegmentIndex == 0 {
            return ExpenseCategories.array.count
        }
        return IncomeCategories.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        
        var name = ""
        
        if categorySegment.selectedSegmentIndex == 0 {
            name = ExpenseCategories.array[indexPath.row].rawValue
        } else {
            name = IncomeCategories.array[indexPath.row].rawValue
        }
        
        cell.generateCell(categoryName: name)
        
        return cell
    }
    
    //MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var imageName = ""
        
        if categorySegment.selectedSegmentIndex == 0 {
            imageName = ExpenseCategories.array[indexPath.row].rawValue
        } else {
            imageName = IncomeCategories.array[indexPath.row].rawValue
        }
        
        category = imageName
        animateCategoryImage(imageName: imageName)
    }
    
    //MARK: SetupUI
    
    //create keyboard
    private func createKeyboardButtons() {
        let buttonTitlesRow1 = ["7", "8", "9"]
        let buttonTitlesRow2 = ["4", "5", "6"]
        let buttonTitlesRow3 = ["1", "2", "3"]
        let buttonTitlesRow4 = [".", "0", "delete"]
        
        var rowXpos: CGFloat = 0.0
        var rowYpos: CGFloat = 0.0
        let buttonHeight: CGFloat = 50.0
        
        for title in buttonTitlesRow1 {
            createButton(xPostion: rowXpos, yPosition: rowYpos, title: title)
            rowXpos += keyboardView.frame.width/3
        }
        
        rowYpos += buttonHeight
        rowXpos = 0.0
        
        for title in buttonTitlesRow2 {
            createButton(xPostion: rowXpos, yPosition: rowYpos, title: title)
            rowXpos += keyboardView.frame.width/3
        }
        
        rowYpos += buttonHeight
        rowXpos = 0.0
        
        for title in buttonTitlesRow3 {
            createButton(xPostion: rowXpos, yPosition: rowYpos, title: title)
            rowXpos += keyboardView.frame.width/3
        }
        
        rowYpos += buttonHeight
        rowXpos = 0.0
        
        for title in buttonTitlesRow4 {
            createButton(xPostion: rowXpos, yPosition: rowYpos, title: title)
            rowXpos += keyboardView.frame.width/3
        }
        
    }
    
    private func createButton(xPostion: CGFloat, yPosition: CGFloat, title: String) {
        
        let button = UIButton(frame: CGRect(x: xPostion, y: yPosition, width: keyboardView.frame.width/3, height: 50.0))
        
        button.setBackgroundColor(UIColor(red: 128/255, green: 204/255, blue: 253/255, alpha: 1.0), for: .highlighted)
        
        if title != "delete" {
            button.setTitle(title, for: .normal)
        } else {
            button.setImage(UIImage(named: "keyboardDelete"), for: .normal)
        }
        
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.addTarget(self, action: #selector(keyboardButtonPressed(_:)), for: .touchUpInside)
        
        self.keyboardView.addSubview(button)
    }
    
    @objc func keyboardButtonPressed(_ sender: UIButton!) {
        
        if sender.titleLabel?.text != nil {
            
            if sender.titleLabel?.text != "." {
                //its a number
                
                if amountText.contains(".") {
                    //adding decimals
                    //dont add more then 2 decimals after the dot
                    
                    if canAddDecimals(numberString: amountText) {
                        amountText += sender.titleLabel!.text!
                    }
                    
                } else {
                    //if we are pressing 0 as first number ignore
                    if amountText.count == 0 && sender.titleLabel?.text == "0" {
                        //                        print("ignoring 1st 0")
                    } else {
                        //adding numbers
                        amountText += sender.titleLabel!.text!
                    }
                }
                
            } else {
                //its a dot, do 1 time
                if !amountText.contains(".") {
                    amountText += sender.titleLabel!.text!
                }
            }
            
        } else {
            //delete last
            if amountText.count > 0 {
                amountText.removeLast()
                
                //check if we have any number left after deleting
                if amountText.count == 0 {
                    amountText = ""
                }
                
            } else {
                amountText = ""
            }
        }
        
        //update
        if amountText.count > 0 {
            
            //check if the first click was a .
            if amountText == "." {
                amountText = "0."
            }
            amount = Double(amountText)!
            updateLabel()
        } else {
            amount = 0.0
            updateLabel()
        }
    }
    
    
    
    //MARK: Helpers
    
    private func canAddDecimals(numberString: String) -> Bool {
        let decimals = numberString.components(separatedBy: ".").last
        return (decimals != nil && decimals!.count < 2)
    }


}
