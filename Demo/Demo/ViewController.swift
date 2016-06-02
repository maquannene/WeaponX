//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.tableFooterView = UIView()
    }
    
}

extension UIViewController: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}
