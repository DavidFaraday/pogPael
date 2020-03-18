//
//  DashboardViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var incomesView: UIView!
    
    @IBOutlet weak var overviewButtonOutlet: UIButton!
    @IBOutlet weak var expenseButtonOutlet: UIButton!
    @IBOutlet weak var incomeButtonOutlet: UIButton!
    @IBOutlet weak var buttonHolderView: UIView!
    
    var overviewViewController: OverviewViewController? = nil
    var expenseViewController: ExpensesViewController? = nil
    var incomingViewController: IncomingsViewController? = nil

    
    //MARK: ClassVars
    var currentView = 0
    var lineView = UIView()
    
    //MARK: ViewLifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideViews(view: 0)
        animateViewIn(view: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
        self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCenterButton()
        setupLineView()
    }

    
    //MARK: IBActions
    @IBAction func overviewButtonPressed(_ sender: Any) {
        hideViews(view: 0)
        animateViewIn(view: 0)
    }
    
    @IBAction func expenseButtonPressed(_ sender: Any) {
        hideViews(view: 1)
        animateViewIn(view: 1)
    }
    
    @IBAction func incomeButtonPressed(_ sender: Any) {
        hideViews(view: 2)
        animateViewIn(view: 2)
    }
    
    
    
    //MARK: Animations
    func animateViewIn(view: Int) {
        
        hideCharts()

        UIView.animate(withDuration: 0.7) {
            switch view {
            case 0:

                self.overviewViewController?.updateChartWithData()

                self.lineView.frame.origin.x = self.overviewButtonOutlet.frame.origin.x

                self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX
                if self.currentView == 2 {
                    self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                } else if self.currentView == 1 {
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                }
                
            case 1:
                self.expenseViewController?.updateChartWithData()

                self.lineView.frame.origin.x = self.expenseButtonOutlet.frame.origin.x
                self.incomingViewController?.incomingChart.isHidden = true

                if self.currentView == 0 {
                    //come from right
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX
                    self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX - (self.overviewView.frame.width + 10)
                    
                } else if self.currentView == 2 {
                    //come from left
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX
                    self.incomesView.frame.origin.x = AnimationManager.screenBounds.maxX + 10
                }
                
            case 2:
                self.lineView.frame.origin.x = self.incomeButtonOutlet.frame.origin.x

                self.incomesView.frame.origin.x = AnimationManager.screenBounds.minX
                self.incomingViewController?.updateChartWithData()
                
                if self.currentView == 0 {
                    self.overviewView.frame.origin.x = AnimationManager.screenBounds.minX - (self.overviewView.frame.width + 10)
                    
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX - (self.expensesView.frame.width + 10)
                    
                } else if self.currentView == 1 {
                    self.expensesView.frame.origin.x = AnimationManager.screenBounds.minX - (self.expensesView.frame.width + 10)
                }
            default:
                return
            }
            
            self.currentView = view
        }
        
    }
    
    
    func hideViews(view: Int) {
        //so that the expense view is not visible when we switch sides
        switch view {
        case 0:
            if self.currentView == 2 {
                expensesView.isHidden = true
            }
        case 1:
            expensesView.isHidden = false
        case 2:
            if self.currentView == 0 {
                expensesView.isHidden = true
            }
        default:
            return
        }
    }
    
    func hideCharts() {
        //hide charts with delay so that we unhide them to show with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.overviewViewController?.incomeChart.isHidden = true
            self.overviewViewController?.expensesChart.isHidden = true
            self.expenseViewController?.expensesChart.isHidden = true
            self.incomingViewController?.incomingChart.isHidden = true
        })
    }
    
    //MARK: SetupLineView
    func setupLineView() {
        
        lineView = UIView(frame: CGRect(x: 0, y: buttonHolderView.frame.height-1, width: incomeButtonOutlet.frame.width, height: 1))
        lineView.backgroundColor = UIColor.lightGray
        
        buttonHolderView.addSubview(lineView)
    }
    

    //MARK: CustomMiddleButton
    
    func setupCenterButton() {
        let centerButton = UIButton(frame: CGRect(x: 0, y: 10, width: 45, height: 45))

        var centerButtonFrame = centerButton.frame
        centerButtonFrame.origin.y = (view.bounds.height - centerButtonFrame.height) - 2
        centerButtonFrame.origin.x = view.bounds.width/2 - centerButtonFrame.size.width/2
        centerButton.frame = centerButtonFrame
        
        centerButton.layer.cornerRadius = 35
        tabBarController?.tabBar.addSubview(centerButton)
        
        centerButton.setBackgroundImage(#imageLiteral(resourceName: "general"), for: .normal)
        centerButton.addTarget(self, action: #selector(centerButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }

    

    // MARK: - Centre button Actions
    
    @objc private func centerButtonAction(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "overviewSegue":
            self.overviewViewController = segue.destination as? OverviewViewController
        case "expenseSegue":
            self.expenseViewController = segue.destination as? ExpensesViewController
        case "incomingSegue":
            self.incomingViewController = segue.destination as? IncomingsViewController

        default:
            break
        }
    }

    

}
