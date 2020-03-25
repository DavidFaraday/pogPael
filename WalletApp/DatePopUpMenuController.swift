//
//  DatePopUpMenuController.swift
//  WalletApp
//
//  Created by David Kababyan on 24/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol DatePopUpMenuControllerDelegate {
    
    func didSelectDateFromPicker(_ month: Int?, year: Int)
    func didSelectDateSegment(_ selectedIndex: Int)
    func dateBackgroundTapped()
}

class DatePopUpMenuController: UIView {

    //MARK: - IBOutlets
    @IBOutlet weak var topHandleBar: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var datePickerSegmentedController: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIPickerView!
    
    
    
    //MARK: - Vars
    var delegate: DatePopUpMenuControllerDelegate?
    
    var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var monthNumbers: [Int] = []
    var years: [Int] = []

    //MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DatePopUpMenu", owner: self, options: nil)
        contentView.fixInView(self)
        topHandleBar.layer.cornerRadius = 5
        
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.addTarget(self, action: #selector(self.backgroundTap))
        
        contentView.addGestureRecognizer(backgroundTap)
        contentView.isUserInteractionEnabled = true
        
        setupDateComponents()
        
        datePicker.delegate = self
        datePicker.dataSource = self
        
        selectCurrentDates()
    }
    
    //MARK: - IBActions
    
    @IBAction func datePickerSegmentedValueChanged(_ sender: UISegmentedControl) {
        
        datePicker.reloadAllComponents()
        selectCurrentDates(sender.selectedSegmentIndex == 2)
        delegate?.didSelectDateSegment(sender.selectedSegmentIndex)
    }
    
    
    @objc private func backgroundTap() {
        delegate?.dateBackgroundTapped()
    }

    

    //MARK: - Setup pickers

    private func setupDateComponents() {

        let currentYear = Calendar.current.component(.year, from: Date())
            
        let startDate = currentYear - 15
        let endYear = currentYear + 15
        
        for year in startDate...endYear {
            years.append(year)
        }

        for i in 1...12 {
            monthNumbers.append(i)
        }
        
    }

    
    private func selectCurrentDates(_ yearOnly: Bool = false) {
        
        if yearOnly {

            let currentYearIndex = years.index(of: calendarComponents(Date()).year ?? 2019)
            datePicker.selectRow(currentYearIndex!, inComponent: 0, animated: true)
        } else {

            let currentYearIndex = years.index(of: calendarComponents(Date()).year ?? 2019)
            let currentMonthIndex = monthNumbers.index(of: calendarComponents(Date()).month ?? 1)
            
            datePicker.selectRow(currentMonthIndex!, inComponent: 0, animated: true)
            datePicker.selectRow(currentYearIndex!, inComponent: 1, animated: true)

        }

    }

}


extension DatePopUpMenuController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return datePickerSegmentedController.selectedSegmentIndex == 2 ?  1 : 2
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            if datePickerSegmentedController.selectedSegmentIndex == 2 {
                
                return "\(years[row])"
            } else {
                
                return "\(monthNames[row])"
            }
        case 1:
            
            return "\(years[row])"
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
      
            return datePickerSegmentedController.selectedSegmentIndex == 2 ? years.count : monthNames.count
        case 1:
            return years.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if datePickerSegmentedController.selectedSegmentIndex == 2 {
            
            let year = years[pickerView.selectedRow(inComponent: 0)]
            delegate?.didSelectDateFromPicker(nil, year: year)

        } else {
            let monthName = monthNames[pickerView.selectedRow(inComponent: 0)]
            let monthNumber = monthNumbers[pickerView.selectedRow(inComponent: 0)]
            let year = years[pickerView.selectedRow(inComponent: 1)]
            
            delegate?.didSelectDateFromPicker(monthNumber, year: year)
        }
    }
}
