//
//  StackTableViewController.swift
//  ShareUploadSwift
//
//  Created by Jeremy Levine on 9/23/14.
//  Copyright (c) 2014 Jeremy Levine. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreGraphics

protocol StackTableViewControllerDelegate {
    func didSelectOptionAtIndexPath(indexPath: NSIndexPath) -> Void
}


class StackTableViewController: UITableViewController {

    var size: CGSize?
    var optionNames: NSMutableArray = []
    var delegate: StackTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.alpha = 0.5
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> NSInteger{
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.optionNames[indexPath.row] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectOptionAtIndexPath(indexPath)
    }
    
}