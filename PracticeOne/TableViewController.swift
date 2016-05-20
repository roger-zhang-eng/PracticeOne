//
//  TableViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

struct tableUpdateValue {
    var index_path: NSIndexPath?
    var headline: String
    var slugline: String
    var imgview: Bool
    var imgDownloaded: Bool
    var imgUrl: String?
    var image: UIImage?
    var tinyUrl: String
}

class TableViewController: UITableViewController,FetchImageProtocol,DataManagerProtocol {
    
    @IBOutlet var newsTableView: UITableView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var stopLoadingBtn: UIButton!
    
    var tabledata:DataManager?
    var tableIndexPath = Dictionary<Int,tableUpdateValue>()
    var stopLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //set tableview cell height auto
        newsTableView.rowHeight = UITableViewAutomaticDimension
        

        
        //debug print
        if(self.tabledata!.database_exist) {
            
            self.loadingIndicator.hidesWhenStopped = true
            print("In viewDidLoad: Recoreds -> \(self.tabledata!.database!.count)")
            
            for i in 1...self.tabledata!.database!.count {
                let rowData = tabledata!.database![i-1]
                let dateline_str = rowData["dateLine"].stringValue
                print("cell[\(i-1)] dateLine: \(dateline_str)")
            }
            
        } else {
            print("In viewDidLoad: database does not exist")
            self.loadingIndicator.hidesWhenStopped = true
            stopLoadingBtn.hidden = false
            self.loadingIndicator.startAnimating()
            //catch the database from JSON URL
            //loadTableViewData()
        }
        

    }

    @IBAction func stopLoadingURL(sender: UIButton) {
        
        self.stopLoading = true
        stopLoadingBtn.hidden = true
        self.loadingIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("In viewWillAppear !")
        super.viewWillAppear(animated)
        deselectAllRows()
    }
    
    func deselectAllRows() {
        if let selectedRows = newsTableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    func loadTableViewData()-> Void
    {
        //set the delegate for the task delay in didReceiveURLResults
        tabledata!.delegate = self
        
        // ######  Use SwiftyJSON class (github) to parse elements  ###########
        //tabledata.getDataFromFile { (data:NSData) -> Array<JSON>? in
        tabledata!.getDataFromURL { (data:NSData) -> Array<JSON>? in
            
            let datasource = JSON(data: data)
            
            if let newsrecords = datasource["items"].array {
                print("JSON elements array has \(newsrecords.count) records")
                
                //only when JSON data could be parsed, set the database_exist true, otherwise database_exist is still default false
                self.tabledata!.database_exist = true
            
                return newsrecords
            } else {
                return nil
            }
        }//end of DataManager get data closure
    
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(!self.tabledata!.database_exist) {
            return 160
        } else {
        
            if(tableIndexPath[indexPath.row]!.imgview) {
                return 200
            } else {
                return 160
            }
        }
        
        
    }
    
    
    @IBAction func RefreshBtn(sender: UIButton) {
        
        tableIndexPath.removeAll(keepCapacity: false)
        tabledata!.resetAll()
        self.stopLoading = false
        self.stopLoadingBtn.hidden = false
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.startAnimating()
        
        self.newsTableView.reloadData()
        
        loadTableViewData()
        
        //debug print
        /*if(self.tabledata.database_exist) {
            println("In RefreshBtn: Recoreds -> \(self.tabledata.database!.count)")
        
            for i in 1...self.tabledata.database!.count {
                let rowData = tabledata.database![i-1]
                let dateline_str = rowData["dateLine"].stringValue
                println("cell[\(i-1)] dateLine: \(dateline_str)")
            }
            
        } */
        
    }
    
    
    func refresh_cell() {
        if(self.tabledata!.database_exist) {
            self.newsTableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabledata!.database_exist {
          return tabledata!.database!.count
        } else {
            NSLog("In tableView numberofRowsInSecton, tabledata does not get database!")
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("In tableview cellforrowatindexpath:  row \(indexPath.row) ! ")
        
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "NewsCell")
        
        if(tabledata!.database_exist) {
            
            if(tableIndexPath[indexPath.row]!.imgview) {
                return imageCellAtIndexPath(indexPath)

            } else {
                return basicCellAtIndexPath(indexPath)
            }
            
        } else {
            NSLog("In tableview cellForRowAtIndexPath, tabledata does not have database!")
            let cell = newsTableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! BasicCell
            
            return cell
        }
        

        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("The selected cell's row \(indexPath.row)")
    }

    
    func startDownloadIcon(index: Int) {
        
        //If the image is in downloading, avoid to download again.
        if(self.tableIndexPath[index]!.imgDownloaded) {
            return
        }
        
        self.tableIndexPath[index]!.imgDownloaded = true
        let imgURL = NSMutableURLRequest(URL: NSURL(string:tableIndexPath[index]!.imgUrl!)!)
        let fetchimage = FetchImage(val:index)
        fetchimage.delegate = self
        fetchimage.httpGet(imgURL) {
            (resultString, error) -> Void in
            fetchimage.callback(result: resultString, error: error)
        }
    
    }
    
    
    func imageCellAtIndexPath(indexPath:NSIndexPath) -> ImageCell {
        let cell = newsTableView.dequeueReusableCellWithIdentifier("NewsImgCell", forIndexPath: indexPath) as! ImageCell

        print("cell of row \(indexPath.row) has existed, reuse it ! ")
        
        cell.headline.text = tableIndexPath[indexPath.row]!.headline
        cell.slugline.text = tableIndexPath[indexPath.row]!.slugline
        
        if tableIndexPath[indexPath.row]!.imgview {
            print("cell of row \(indexPath.row) has image ! ")
            
            // retrieve image data from url if the image is null
            if(tableIndexPath[indexPath.row]!.image == nil) {
                cell.thumnail.image = UIImage(named: "Placeholder")
                self.tableIndexPath[indexPath.row]!.index_path = indexPath
                startDownloadIcon(indexPath.row)

            } else {
                
                cell.thumnail.image = tableIndexPath[indexPath.row]?.image!
            } //end of if(tableIndexPath[indexPath.row]!.image == nil)
            
        } else {
            cell.thumnail.image = nil
            print("cell of row \(indexPath.row) does not has image ! ")
        }
        
        return cell
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        
        let cell = newsTableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! BasicCell
        
        //when the database records exist, return the cell's needed information directly.
        if(tableIndexPath[indexPath.row] != nil) {
            
            print("cell of row \(indexPath.row) has existed, reuse it ! ")
            
            cell.headline.text = tableIndexPath[indexPath.row]!.headline
            cell.slugline.text = tableIndexPath[indexPath.row]!.slugline
            
        } else {
            NSLog("In tableview cellForRowAtIndexPath, row \(indexPath.row) does not have record, but database exist!")
        }

        return cell
    }
    
    func didReceiveURLResults(timeval:Int?) {
        
        // Delay execution of my block for 3 seconds to simulate the network speed low
        // This delay is only for simulating the network delay, and demo the loading waiting time animation!
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,Int64(0.5 * Double(NSEC_PER_SEC)))
    
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("Database is got, but delay time to call back!")
            
            //stop loading indicator, and reload tableview data to display
            self.loadingIndicator.stopAnimating()
            
            //do the database set according to the stopLoading Button
            //Only when all the records are got, the tableview is allowed to be displayed.
            if self.stopLoading {
                self.tableIndexPath.removeAll(keepCapacity: false)
                self.tabledata!.resetAll()
            } else {
                print("Got all the URL data now!")
                self.stopLoadingBtn.hidden = true
                
                //fill records text data into tableview database
                for (index, rowData) in (self.tabledata!.database!).enumerate() {
                    let urlstr = rowData["thumbnailImageHref"].string
                    var imgExist = false
                    if urlstr != nil {
                        if(urlstr!.characters.count > 5) {
                            imgExist = true
                        } else {
                            NSLog("thumbnailImageHref in row \(index) is too short, and invalid!")
                        }
                        
                    } else {
                        NSLog("No thumbnailImageHref in row \(index)")
                    }
                    
                    let cell_all_data = tableUpdateValue(index_path: nil,headline: rowData["headLine"].stringValue, slugline: rowData["slugLine"].stringValue, imgview: imgExist,imgDownloaded: false, imgUrl:urlstr, image: nil,tinyUrl:rowData["tinyUrl"].stringValue)
                    
                    self.tableIndexPath[index] = cell_all_data
                    
                } // end of for (index, rowData) in enumerate(self.tabledata.database!)
                
                self.tableView!.reloadData()
            }
        }// end of dispatch_after
    
    
    }
    
    func didReceiveImgResults(index:Int?,img_data: UIImage?) {
        
        let table_update = tableIndexPath[index!]!
        //table_update.cell_data.imageView?.image = img_data!
        
        tableIndexPath[index!]?.image = img_data
        
        print("Row \(index) image has been downloaded!")
        
        let indexPath = table_update.index_path!
        
        //Only update the image Row's image data in tableview
        let cell = self.newsTableView.cellForRowAtIndexPath(indexPath) as! ImageCell
        cell.thumnail.image = img_data
        
        /* // update all the visible Rows of tableview (not efficient)
        //select the updated Row from the visible Rows
        let visiblePaths_array = self.newsTableView.indexPathsForVisibleRows()!
        
        for element in visiblePaths_array {
            let indexPath = element as NSIndexPath
            if(index == indexPath.row) {
                println("Row \(index) is updated by the image icon!")
                self.newsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.None)
            }
            
        } */
        
        
    } // end of didReceiveAPIResults func
    
    
    func loadImageForScreenRows() {
        if self.tabledata!.database_exist {
            let visibleRows = self.newsTableView.indexPathsForVisibleRows! as [NSIndexPath]
            for  indexPath in visibleRows {
                let record = self.tableIndexPath[indexPath.row]!
                if record.imgview {
                    if record.image == nil {
                        print("In loadImageForScreenRows:  row \(indexPath.row) download image ")
                        let cell = self.newsTableView.cellForRowAtIndexPath(indexPath) as! ImageCell
                        cell.thumnail.image = UIImage(named: "Placeholder")
                        self.tableIndexPath[indexPath.row]?.index_path = indexPath
                        startDownloadIcon(indexPath.row)
                    }
                } // end of record.imgview
                
            } // end of for  indexPath in visibleRows
        }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            if let indexPath = self.newsTableView.indexPathForSelectedRow {
                print("Open Web Page in the row \(indexPath.row)")
                
                let weburl = tableIndexPath[indexPath.row]!.tinyUrl
                
                (segue.destinationViewController as! WebViewController).url = NSURL(string: weburl)
                
            }
        
    }
    
    // #pragma mark - UIScrollViewDelegate
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            loadImageForScreenRows()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImageForScreenRows()
    }

    
}
