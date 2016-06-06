//
//  BaseViewController.swift
//  Demo
//
//  Created by 马权 on 6/6/16.
//  Copyright © 2016 马权. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let backButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("Back", forState: .Normal )
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(BaseViewController.backAction), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(backButton)
    }
    
    func backAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}