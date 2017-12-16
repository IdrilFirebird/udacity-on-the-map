//
//  PinListViewController.swift
//  OnTheMap
//
//  Created by Sebastian on 29.11.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

class PinListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "dataUpdated"), object: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = Global.sharedInstance().students[indexPath.row].link {
            UIApplication.shared.open(url)
        } else {
            showErrorAlert(viewController: self, message: "That's no link")
        }
    }
    
    @objc func refreshTable() {
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = Global.sharedInstance().students[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TableCell")
        
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = "\(student.link?.absoluteString ?? "")"
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global.sharedInstance().students.count
    }
    
}

