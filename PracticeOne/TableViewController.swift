//
//  TableViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

struct tableUpdateValue {
    var cell_data: UITableViewCell
    var index_path: NSIndexPath
    var headline: String
    var slugline: String
    var tinyUrl: String
}

class TableViewController: UITableViewController,FetchImageProtocol {
    
    @IBOutlet var newsTableView: UITableView!
    
    var tabledata=DataManager()
    var tableIndexPath = Dictionary<Int,tableUpdateValue>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableViewData()
        
        //debug print
        if(self.tabledata.database_exist) {
            println("In viewDidLoad: Recoreds -> \(self.tabledata.database!.count)")
            
            for i in 1...self.tabledata.database!.count {
                let rowData = tabledata.database![i-1]
                let dateline_str = rowData["dateLine"].stringValue
                println("cell[\(i-1)] dateLine: \(dateline_str)")
            }
            
        }

    }

    func loadTableViewData()-> Void
    {
        // ######  Use SwiftyJSON class (github) to parse elements  ###########
        //tabledata.getDataFromFile { (data:NSData) -> Array<JSON>? in
        tabledata.getDataFromURL { (data:NSData) -> Array<JSON>? in
            
            let datasource = JSON(data: data)
            
            if let newsrecords = datasource["items"].arrayValue {
                println("JSON elements array has \(newsrecords.count) records")
                
               /* if let test_ele1 = datasource["items"][0]["headLine"].stringValue {
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
                */
            
                return newsrecords
            } else {
                return nil
            }
        }//end of DataManager get data closure
    
    }
    
    @IBAction func RefreshBtn(sender: UIButton) {
        
        tableIndexPath.removeAll(keepCapacity: false)
        tabledata.resetAll()
        loadTableViewData()
        
        //debug print
        if(self.tabledata.database_exist) {
            println("In RefreshBtn: Recoreds -> \(self.tabledata.database!.count)")
        
            for i in 1...self.tabledata.database!.count {
                let rowData = tabledata.database![i-1]
                let dateline_str = rowData["dateLine"].stringValue
                println("cell[\(i-1)] dateLine: \(dateline_str)")
            }
            
        }
        
        
        
        self.newsTableView.reloadData()

        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabledata.database_exist {
          return tabledata.database!.count
        } else {
            NSLog("In tableView numberofRowsInSecton, tabledata does not get database!")
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 1) {
            println("In tableview cellforrowatindexpath:  row 1 ! ")
        }

        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "NewsCell")
        let cell = newsTableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as UITableViewCell
        
        if(tableIndexPath[indexPath.row] != nil) {
            if(indexPath.row == 1) {
                println("cell of row 1 has existed, reuse it ! ")
            }
            
            //return tableIndexPath[indexPath.row]!.cell_data
            return cell
        }
        
        if(tabledata.database_exist) {
            
            let rowData = tabledata.database![indexPath.row]
            cell.textLabel!.text = rowData["headLine"].stringValue
            cell.detailTextLabel!.text = rowData["slugLine"].stringValue
            
            var cell_all_data = tableUpdateValue(cell_data: cell, index_path: indexPath, headline: rowData["headLine"].stringValue!, slugline: rowData["slugLine"].stringValue!,tinyUrl:rowData["tinyUrl"].stringValue!)
            tableIndexPath[indexPath.row] = cell_all_data
            
            //let imgURL = NSURL(string:"https://www.alamo.edu/uploadedImages/NVC/Website_Assets/Images/News_and_Events_Sets/youtube-logo.jpg");
            //let imgURL:NSURL? = NSURL(string: rowData["thumbnailImageHref"].stringValue!)
            
            if let urlstr = rowData["thumbnailImageHref"].stringValue {
                if(countElements(urlstr) > 5) {
                    NSLog("thumbnailImageHref in row \(indexPath.row) is \(urlstr)")
                    var imgURL = NSMutableURLRequest(URL: NSURL(string:rowData["thumbnailImageHref"].stringValue!)!)
                    
                    var fetchimage = FetchImage(val:indexPath.row)
                    fetchimage.delegate = self
                    fetchimage.httpGet(imgURL) {
                        (resultString, error) -> Void in
                        fetchimage.callback(result: resultString, error: error)
                    }
                } else {
                    NSLog("thumbnailImageHref in row \(indexPath.row) is too short, and invalid!")
                }
            
            } else {
                NSLog("No thumbnailImageHref in row \(indexPath.row)")
            }
            
            //let imgData = NSData(contentsOfURL: imgURL!)
            //cell.imageView!.image = UIImage(data: imgData!)
            
            //cell.reloadInputViews()
            
            if(indexPath.row == 1) {
                NSLog("cell[1] textLabel : \(cell.textLabel!.text)")
                NSLog("cell[1] detailText : \(cell.detailTextLabel!.text)")
                //NSLog("imgURL : \(urlstr)")
            }
            
        } else {
            NSLog("In tableview cellForRowAtIndexPath, tabledata does not have database!")
        }
        
        return cell
        
    }
    
    func didReceiveImgResults(index:Int?,img_data: UIImage?) {
        
        let table_update = tableIndexPath[index!]!
        
        dispatch_async(dispatch_get_main_queue(), {
        
                table_update.cell_data.imageView?.image = img_data!
                
                //cell_data?.reloadInputViews()
               
                self.newsTableView.reloadRowsAtIndexPaths([table_update.index_path], withRowAnimation: .None)
                //self.newsTableView.reloadData()
        
            
        }) // end of dispatch_async
    } // end of didReceiveAPIResults func
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.newsTableView.indexPathForSelectedRow() {
                //let vehicle = vehicles[indexPath.row]
                let weburl = tableIndexPath[indexPath.row]!.tinyUrl
                
                (segue.destinationViewController as WebViewController).url = NSURL(string: weburl)
                
            }
        }
    }

    
}
