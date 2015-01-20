//
//  TableViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,FetchImageProtocol {
    
    var tabledata=DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableViewData()

    }

    func loadTableViewData()-> Void
    {
        // ######  Use SwiftyJSON class (github) to parse elements  ###########
        tabledata.getDataFromFile { (data:NSData) -> Array<JSON>? in
            
            let datasource = JSON(data: data)
            
            if let newsrecords = datasource["items"].arrayValue {
                println("JSON elements array has \(newsrecords.count) records")
                
                if let test_ele1 = datasource["items"][0]["headLine"].stringValue {
                    println("The 1st element headline : \(test_ele1)")
                } else {
                    println("don't get the test element!")
                }
                if let test_ele2 = datasource["items"][0]["slugLine"].stringValue {
                    println("The 1st element slugline : \(test_ele2)")
                } else {
                    println("don't get the test element!")
                }
                if let test_ele3 = datasource["items"][0]["thumbnailImageHref"].stringValue {
                    println("The 1st element imgHref : \(test_ele3)")
                } else {
                    println("don't get the test element!")
                }
            
                return newsrecords
            } else {
                return nil
            }
        }//end of DataManager get data from file
    
    }
    
    @IBAction func RefreshBtn(sender: UIButton) {
        if(tabledata.database_exist) {
        println("Recoreds: \(tabledata.database!.count)")
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabledata.database_exist {
          return tabledata.database!.count
        } else {
            NSLog("tabledata does not get database!")
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "NewsCell")
        
        NSLog("In tableview cellForRowAtIndexPath")
        
        if(tabledata.database_exist) {
            let rowData = tabledata.database![indexPath.row]
            cell.textLabel!.text = rowData["headLine"].stringValue
            cell.detailTextLabel!.text = rowData["slugLine"].stringValue
            
            //let imgURL = NSURL(string:"https://www.alamo.edu/uploadedImages/NVC/Website_Assets/Images/News_and_Events_Sets/youtube-logo.jpg");
            //let imgURL:NSURL? = NSURL(string: rowData["thumbnailImageHref"].stringValue!)
            
            if let urlstr = rowData["thumbnailImageHref"].stringValue {
                NSLog("thumbnailImageHref in row \(indexPath.row) is \(urlstr)")
                var imgURL = NSMutableURLRequest(URL: NSURL(string:rowData["thumbnailImageHref"].stringValue!)!)
            
                var fetchimage = FetchImage(val:cell.imageView!)
                fetchimage.delegate = self
                fetchimage.httpGet(imgURL) {
                    (resultString, error) -> Void in
                    fetchimage.callback(result: resultString, error: error)
                }
            } else {
                NSLog("No thumbnailImageHref in row \(indexPath.row)")
            }
            
            //let imgData = NSData(contentsOfURL: imgURL!)
            //cell.imageView!.image = UIImage(data: imgData!)
            
            if(indexPath.row == 0) {
                NSLog("cell textLabel : \(cell.textLabel!.text)")
                NSLog("cell detailText : \(cell.detailTextLabel!.text)")
                //NSLog("imgURL : \(urlstr)")
            }
            
        } else {
            NSLog("tabledata does not have database!")
        }
        
        return cell
        
    }
    
    func didReceiveImgResults(img_view:UIImageView?,img_data: UIImage?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            if (img_view != nil) {
                img_view!.image = img_data!
            }
            
        }) // end of dispatch_async
    } // end of didReceiveAPIResults func
    
}
