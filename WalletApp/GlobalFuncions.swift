//
//  Helpers.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import UIKit
import Charts


let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


func calendarComponents(_ ofDate: Date) -> DateComponents {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekOfYear, .month, .year], from: ofDate)
    return components
}

//func monthNameFrom(_ number: Int) -> String {
//    print("/////", number)
//    return monthNames[number]
//}


func getImageFor(_ categoryName: String) -> UIImage {
    return UIImage(named: categoryName.lowercased())!
}


func ColorFromChart(_ _row: Int) -> UIColor {
    var row = _row
    if row > 9 {
        row = Int.random(in: 0 ..< 9)
    }
    return ChartColorTemplates.joyful()[row]
}

func ColorFromExpenseType(_ isExpense: Bool) -> UIColor {

    return isExpense ? .expenseColor : .incomeColor
}

func ColorFromAmount(_ amount: Double) -> UIColor {

    return amount >= 0.0 ? .incomeColor : .expenseColor
}

func convertToCurrency(number: Double) -> String {
        
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    // localized to your grouping and decimal separator
    currencyFormatter.locale = Locale.current
    
    let priceString = currencyFormatter.string(from: NSNumber(value: number))!

    return priceString
}


func formatStringDecimalSize(_ stringToFormat: String, mainNumberSize: CGFloat, decimalNumberSize: CGFloat) -> NSAttributedString {
    
    let number = stringToFormat.split(separator: ".").first!
    let decimalPoint = stringToFormat.split(separator: ".").last!
    
    let numberString = NSAttributedString(string: String(number), attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: mainNumberSize)])
    let decimalString = NSAttributedString(string: String(decimalPoint), attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: decimalNumberSize)])
    let dotString = NSAttributedString(string: ".")
        

    let finalText = NSMutableAttributedString()
    finalText.append(numberString)
    
    if decimalPoint != "00" {
        finalText.append(dotString)
        finalText.append(decimalString)
    }

    
    return finalText
}



