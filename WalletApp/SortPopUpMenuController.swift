//
//  PopupViewController.swift
//  slideUpView
//
//  Created by David Kababyan on 23/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol SortPopupMenuControllerDelegate {
    
    func dateButtonPressed()
    func amountButtonPressed()
    func categoryButtonPressed()
    func sortBackgroundTapped()

}

class SortPopUpMenuController: UIView {
    
    //MARK: - IBOutlets

    @IBOutlet weak var topHandleBar: UIView!
    @IBOutlet var contentView: UIView!
    
    
    //MARK: - Vars
    var delegate: SortPopupMenuControllerDelegate?

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
        Bundle.main.loadNibNamed("PopUpMenu", owner: self, options: nil)
        contentView.fixInView(self)
        topHandleBar.layer.cornerRadius = 3
        
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.addTarget(self, action: #selector(self.backgroundTap))
        
        contentView.addGestureRecognizer(backgroundTap)
        contentView.isUserInteractionEnabled = true
    }
    
    
    //MARK: - IBActions
    @objc private func backgroundTap() {
        delegate?.sortBackgroundTapped()
    }
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        delegate?.dateButtonPressed()

    }
    
    @IBAction func amountButtonPressed(_ sender: Any) {
        delegate?.amountButtonPressed()

    }
    
    @IBAction func categoryButtonPressed(_ sender: Any) {
        delegate?.categoryButtonPressed()

    }
        
}


