//
//  SettingsTableViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 31/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    //MARK: - UIOutlets
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - View Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppVersion()
        tableView.tableFooterView = UIView()
    }
    
    //MARK: IBActions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        
        let text = "Hey! Check out this cool money tracker app that I am using, its called PiggyB Pro \(kAPPURL)"
        
        let objectsToShare: [Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityViewController.setValue("Check out this cool app PiggyB Pro", forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func rateOnAppStoreButtonPressed(_ sender: Any) {
        rateApp()
    }
    
    @IBAction func facebookLikeButtonPressed(_ sender: Any) {
        likeFacebook()
    }
    
    
    
    //MARK: - Helpers
    private func rateApp() {
        if let url = URL(string: kAPPURL) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    private func likeFacebook() {
        if let url = URL(string: kFACEBOOKURL) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    private func setAppVersion() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        appVersionLabel.text = "App version: \(appVersion ?? "1.0")"
    }
    

    
    //MARK: TableViewDelegates
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        headerView.backgroundColor = UIColor(named: "navigationBackground")
        
        if section == 0 {
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 30))

            titleLabel.text = "General"
            headerView.addSubview(titleLabel)
        }

        return headerView
    }

}
