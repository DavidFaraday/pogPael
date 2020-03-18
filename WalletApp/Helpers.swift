//
//  Helpers.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import UIKit

func getImageFor(_ categoryName: String) -> UIImage {
    return UIImage(named: categoryName)!
}


func convertToCurrency(number: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    // localize to your grouping and decimal separator
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


extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}

