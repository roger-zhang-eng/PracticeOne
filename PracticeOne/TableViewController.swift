//
//  TableViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
    // ######  Use SwiftyJSON class (github) to parse elements  ###########
        DataManager.getDataFromFile { (data:NSData) -> Void in
            
            let datasource = JSON(data: data)
            if let test_ele = datasource["items"][0]["headLine"].stringValue {
                println("The 1st element headline : \(test_ele)")
            } else {
                println("don't get the test element!")
            }
            
        }//end of DataManager get data from file

    }
        
}
