//
//  CalendarViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 22/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import KDCalendar

protocol CalendarViewControllerDelegate {
    func didSelectDate(_ selectedDate: Date)
}

class CalendarViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var calendarView: CalendarView!
    
    //MARK: - Vars
    var expenseDate: Date?
    var delegate: CalendarViewControllerDelegate?
    
    //MARK: - View Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if expenseDate != nil {
            setSelectedDate()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendar()

    }
    
    
    //MARK: - SetupCalendar View

    private func setupCalendar() {
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        self.calendarView.setDisplayDate(Date(), animated: false)
        
        calendarView.direction = .vertical
        
        let myCalendarStyle = CalendarView.Style()
        myCalendarStyle.cellTextColorWeekend = .systemRed
        myCalendarStyle.firstWeekday = .monday
        myCalendarStyle.locale = Locale.current //sets device settings for format
        myCalendarStyle.headerBackgroundColor = UIColor.systemBackground
        myCalendarStyle.weekdaysBackgroundColor = UIColor.systemBackground
        myCalendarStyle.cellShape = .round
        calendarView.marksWeekends = true
        
        calendarView.style = myCalendarStyle


    }

    private func setSelectedDate() {
        self.calendarView.selectDate(expenseDate!)
//        self.calendarView.deselectDate(date)//to deselect the date
    }

}

extension CalendarViewController: CalendarViewDataSource {
    
    func startDate() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = -5
        let today = Date()
        let fiveYearsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)
        return fiveYearsAgo ?? Date()
    }
    
    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = +10
        let today = Date()
        let fiveYearsAfter = self.calendarView.calendar.date(byAdding: dateComponents, to: today)
        return fiveYearsAfter ?? Date()

    }
    
    func headerString(_ date: Date) -> String? {
        return nil
    }
    
    
}

extension CalendarViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        delegate?.didSelectDate(date)
        self.navigationController?.popViewController(animated: true)
    }
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        return true
    }
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {

    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {
    }
    
    
}
