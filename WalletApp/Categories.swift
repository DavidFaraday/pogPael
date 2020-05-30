//
//  Categories.swift
//  WalletApp
//
//  Created by David Kababyan on 30/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation

enum ExpenseCategories : String, Codable {
    
    case general
    case shopping
    case eatingOut
    case clothes
    case entertainment
    case holiday
    case drinks
    case travel
    case transport
    case petrol
    case gift
    case sports
    case pets
    case baby
    case games
    case health
    case home
    case music
    case school
    case car
    case phone
    case tools
    case ticket
    case bicycle
    case internet
    case gym
    case hairdresser
    case coffee
    case partner
    case tv
    case parking
    case loan
    case rent
    
    static var array: [ExpenseCategories] {
        var a: [ExpenseCategories] = []
        
        switch ExpenseCategories.general {
        case .general:
            a.append(.general); fallthrough
        case .shopping:
            a.append(.shopping); fallthrough
        case .eatingOut:
            a.append(.eatingOut); fallthrough
        case .clothes:
            a.append(.clothes); fallthrough
        case .entertainment:
            a.append(.entertainment); fallthrough
        case .holiday:
            a.append(.holiday); fallthrough
        case .drinks:
            a.append(.drinks); fallthrough
        case .travel:
            a.append(.travel); fallthrough
        case .transport:
            a.append(.transport); fallthrough
        case .petrol:
            a.append(.petrol); fallthrough
        case .gift:
            a.append(.gift); fallthrough
        case .sports:
            a.append(.sports); fallthrough
        case .pets:
            a.append(.pets); fallthrough
        case .baby:
            a.append(.baby); fallthrough
        case .games:
            a.append(.games); fallthrough
        case .health:
            a.append(.health); fallthrough
        case .home:
            a.append(.home); fallthrough
        case .music:
            a.append(.music); fallthrough
        case .school:
            a.append(.school); fallthrough
        case .car:
            a.append(.car); fallthrough
        case .phone:
            a.append(.phone); fallthrough
        case .tools:
            a.append(.tools); fallthrough
        case .ticket:
            a.append(.ticket); fallthrough
        case .bicycle:
            a.append(.bicycle); fallthrough
        case .internet:
            a.append(.internet); fallthrough
        case .gym:
            a.append(.gym); fallthrough
        case .hairdresser:
            a.append(.hairdresser); fallthrough
        case .coffee:
            a.append(.coffee); fallthrough
        case .partner:
            a.append(.partner); fallthrough
        case .tv:
            a.append(.tv); fallthrough
        case .parking:
            a.append(.parking); fallthrough
        case .rent:
            a.append(.rent); fallthrough
        case .loan:
            a.append(.loan);
        }
        return a
    }
    
}


enum IncomeCategories : String {
    
    case salary
    case savings
    case investment
    case general
    case gift
    case home
    case bonus
    case development
    case insurance
    case director
    case rent
    case online
    
    static var array: [IncomeCategories] {
        var a: [IncomeCategories] = []
        
        switch IncomeCategories.salary {
        case .salary:
            a.append(.salary); fallthrough
        case .savings:
            a.append(.savings); fallthrough
        case .investment:
            a.append(.investment); fallthrough
        case .general:
            a.append(.general); fallthrough
        case .gift:
            a.append(.gift); fallthrough
        case .home:
            a.append(.home); fallthrough
        case .bonus:
            a.append(.bonus); fallthrough
        case .development:
            a.append(.development); fallthrough
        case .insurance:
            a.append(.insurance); fallthrough
        case .director:
            a.append(.director); fallthrough
        case .rent:
            a.append(.rent);fallthrough
            case .online:
            a.append(.online);
        return a
        }
    }
}


