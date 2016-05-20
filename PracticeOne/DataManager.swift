//
//  DataManager.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import Foundation

protocol DataManagerProtocol {
    func didReceiveURLResults(timeval:Int?)
}

class DataManager {
    
    var database : Array<JSON>?
    var database_exist = false
    var delegate: DataManagerProtocol?
    
    init() {
        print("DataManager init done!")
    }
    
    func getDataFromFile(success: ((data:NSData) -> Array<JSON>?)) {
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource("testdata", ofType: "json")
            //NSLog("NSData file is: \(filePath!)")
            
            var readError:NSError?
            do {
                let data = try NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.DataReadingUncached)
                    self.database =  success(data: data)
            } catch let error as NSError {
                readError = error
            }
        
        //})
    }
    
    func getDataFromURL(success: ((data:NSData) -> Array<JSON>?)) {
        if let url = NSURL(string: "http://mobilatr.mob.f2.com.au/services/views/9.json") {
            
            //run to get the JSON file from URL by task Asynchronously
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
            //run to get the JSON file from URL synchronously
            //if let data = NSData(contentsOfURL: url){
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    print(error!.localizedDescription)
                } else {
                    self.database =  success(data: data!)
                
                    //call delegate func to trigger 8s delay back to main queue
                    self.delegate?.didReceiveURLResults(3)
                }
                
            } )// end of session.dataTaskWithURL
            task.resume()
            
        } // end of if let url=
    } // end of func getDataFromURL
    
    func resetAll() {
        if(self.database != nil) {
            self.database?.removeAll(keepCapacity: false)
        }
        self.database_exist = false
    }
    
}