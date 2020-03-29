//
//  CustomViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 01/10/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    var centerButton:UIButton!
    
    private var centerButtonTappedOnce: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.bringcenterButtonToFront()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dashboardVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardView")
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "dashboard"), tag: 1)
        let nav1 = UINavigationController(rootViewController: dashboardVC)

        let transactionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionsView")
        transactionVC.tabBarItem = UITabBarItem(title: "Transactions", image: UIImage(named: "transaction"), tag: 2)
        let nav2 = UINavigationController(rootViewController: transactionVC)

        let controller3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddItemView")
        let nav3 = controller3

        let accountVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountView")
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account"), tag: 4)
        let nav4 = UINavigationController(rootViewController: accountVC)


        let settingsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsView")
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 5)
        let nav5 = UINavigationController(rootViewController: settingsVC)


        viewControllers = [nav1, nav2, nav3, nav4, nav5]

        self.setupMiddleButton()
    }
    
    
    // MARK: - Internal Methods
    
    @objc private func centerButtonAction(sender: UIButton) {
        
        let addItemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddItemView")
        
        let vc = self.viewControllers![selectedIndex]
        addItemVC.modalPresentationStyle = .fullScreen
        vc.present(addItemVC, animated: true, completion: nil)
    }
    
    func hideCenterButton() {
        centerButton.isHidden = true
    }
    
    func showCenterButton() {
        centerButton.isHidden = false
        self.bringcenterButtonToFront()
    }
    
    // MARK: - Private methods
    
    private func setupMiddleButton() {
        centerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        var centerButtonFrame = centerButton.frame
        centerButtonFrame.origin.y = tabBar.frame.origin.y - centerButtonFrame.height / 2 - 10
            
//            view.bounds.height - (centerButtonFrame.height + 10)
        centerButtonFrame.origin.x = tabBar.frame.width/2 - centerButtonFrame.size.width/2
        centerButton.frame = centerButtonFrame
        
        centerButton.layer.cornerRadius = centerButtonFrame.height/2
        view.addSubview(centerButton)
        
        centerButton.setImage(UIImage(named: "plus"), for: .normal)
        centerButton.tintColor = UIColor(named: "barUnselectedTintColor") 
        
        centerButton.addTarget(self, action: #selector(centerButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    private func bringcenterButtonToFront() {
        self.view.bringSubviewToFront(self.centerButton)
    }
    
}

