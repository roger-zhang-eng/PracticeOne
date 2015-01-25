//
//  TableViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

struct tableUpdateValue {
    var index_path: NSIndexPath
    var headline: String
    var slugline: String
    var image: UIImage?
    var tinyUrl: String
}

class TableViewController: UITableViewController,FetchImageProtocol,DataManagerProtocol {
    
    @IBOutlet var newsTableView: UITableView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var stopLoadingBtn: UIButton!
    
    var tabledata=DataManager()
    var tableIndexPath = Dictionary<Int,tableUpdateValue>()
    var stopLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoadingBtn.hidden = false
        
        loadTableViewData()
        
        //debug print
        if(self.tabledata.database_exist) {
            println("In viewDidLoad: Recoreds -> \(self.tabledata.database!.count)")
            
            for i in 1...self.tabledata.database!.count {
                let rowData = tabledata.database![i-1]
                let dateline_str = rowData["dateLine"].stringValue
                println("cell[\(i-1)] dateLine: \(dateline_str)")
            }
            
        } else {
            println("In viewDidLoad: database does not exist")
            self.loadingIndicator.hidesWhenStopped = true
            self.loadingIndicator.startAnimating()
        }
        

    }

    @IBAction func stopLoadingURL(sender: UIButton) {
        
        self.stopLoading = true
        self.loadingIndicator.stopAnimating()
    }
    
    override func  viewDidAppear(animated: Bool) {
        println("In viewDidAppear !")
    }
    
    func loadTableViewData()-> Void
    {
        //set the delegate for the task delay in didReceiveURLResults
        tabledata.delegate = self
        
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
        self.stopLoading = false
        self.stopLoadingBtn.hidden = false
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.startAnimating()
        self.newsTableView.reloadData()
        
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
        
        //println("In tableview cellforrowatindexpath:  row \(indexPath.row) ! ")
        
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "NewsCell")
        let cell = newsTableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as UITableViewCell
        
        
        if(tabledata.database_exist) {
            
            //when the database records exist, return the cell's needed information directly.
            if(tableIndexPath[indexPath.row] != nil) {
                
                println("cell of row \(indexPath.row) has existed, reuse it ! ")
                
                cell.textLabel!.text = tableIndexPath[indexPath.row]!.headline
                cell.detailTextLabel!.text = tableIndexPath[indexPath.row]!.slugline
                if tableIndexPath[indexPath.row]!.image != nil {
                    println("cell of row \(indexPath.row) has image ! ")
                    cell.imageView!.image = tableIndexPath[indexPath.row]?.image!
                } else {
                    cell.imageView?.image = nil
                    println("cell of row \(indexPath.row) does not has image ! ")
                }
                
                return cell
            }
            
            //when the tableview run 1st time after database got, run the following codes.
            let rowData = tabledata.database![indexPath.row]
            cell.textLabel!.text = rowData["headLine"].stringValue!
            cell.detailTextLabel!.text = rowData["slugLine"].stringValue
            
            var cell_all_data = tableUpdateValue(index_path: indexPath, headline: rowData["headLine"].stringValue!, slugline: rowData["slugLine"].stringValue!,image: nil,tinyUrl:rowData["tinyUrl"].stringValue!)
            tableIndexPath[indexPath.row] = cell_all_data
            
            //let imgURL = NSURL(string:"https://www.alamo.edu/uploadedImages/NVC/Website_Assets/Images/News_and_Events_Sets/youtube-logo.jpg");
            //let imgURL:NSURL? = NSURL(string: rowData["thumbnailImageHref"].stringValue!)
            
            if let urlstr = rowData["thumbnailImageHref"].stringValue {
                if(countElements(urlstr) > 5) {
                    //NSLog("thumbnailImageHref in row \(indexPath.row) is \(urlstr)")
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
            
            
            /*
            if(indexPath.row == 1) {
                NSLog("cell[1] textLabel : \(cell.textLabel!.text)")
                NSLog("cell[1] detailText : \(cell.detailTextLabel!.text)")
                //NSLog("imgURL : \(urlstr)")
            }*/
            
        } else {
            NSLog("In tableview cellForRowAtIndexPath, tabledata does not have database!")
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("The selected cell's row \(indexPath.row)")
    }
    
    func didReceiveURLResults(timeval:Int?) {
        
        // Delay execution of my block for 8 seconds.
        // This delay is only for simulating the network delay, and demo the loading waiting time animation!
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,Int64(8 * Double(NSEC_PER_SEC)))
    
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            println("Database is got, but delay 10s to call back!")
            
            //stop loading indicator, and reload tableview data to display
            self.loadingIndicator.stopAnimating()
            
            //do the database set according to the stopLoading Button
            //Only when all the records are got, the tableview is allowed to be displayed.
            if self.stopLoading {
                self.tableIndexPath.removeAll(keepCapacity: false)
                self.tabledata.resetAll()
            } else {
                self.stopLoadingBtn.hidden = true
                self.tableView!.reloadData()
            }
        }
    
    
    }
    
    func didReceiveImgResults(index:Int?,img_data: UIImage?) {
        
        let table_update = tableIndexPath[index!]!
        //table_update.cell_data.imageView?.image = img_data!
        
        tableIndexPath[index!]?.image = img_data
        
        dispatch_async(dispatch_get_main_queue(), {
        
               
                self.newsTableView.reloadRowsAtIndexPaths([table_update.index_path], withRowAnimation: .None)
        
            
        }) // end of dispatch_async
        
    } // end of didReceiveAPIResults func
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.newsTableView.indexPathForSelectedRow() {
                println("Open Web Page in the row \(indexPath.row)")
                
                let weburl = tableIndexPath[indexPath.row]!.tinyUrl
                
                (segue.destinationViewController as WebViewController).url = NSURL(string: weburl)
                
            }
        } //end of if segue.identifier
        
    }

    
}
