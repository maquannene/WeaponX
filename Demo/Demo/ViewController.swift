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
    let layouts: [AnyClass] = Helper.allLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.tableFooterView = UIView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layouts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = String(layouts[indexPath.row])
        return cell
    }
}
