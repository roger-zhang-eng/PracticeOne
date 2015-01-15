//
//  DataManager.swift
//  PracticeOne
//
//  Created by Roger Zhang on 15/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import Foundation

class DataManager {
    class func getDataFromFile(success: ((data:NSData) -> Void)) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource("testdata", ofType: "json")
            NSLog("NSData file is: \(filePath!)")
            
            var readError:NSError?
            if let data = NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.DataReadingUncached,
                error:&readError) {
                    success(data: data)
            } })
    }
    
    
}