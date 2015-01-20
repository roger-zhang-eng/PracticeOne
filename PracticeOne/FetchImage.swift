//
//  FetchImage.swift
//  PracticeOne
//
//  Created by Roger Zhang on 20/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit
import Foundation

protocol FetchImageProtocol {
    func didReceiveImgResults(img_view:UIImageView?,img_data: UIImage?)
}

class FetchImage: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    var img:UIImage?
    var imgView:UIImageView?
    
    var delegate: FetchImageProtocol?
    
    typealias CallbackBlock = (result: String, error: String?) -> ()
    var callback: CallbackBlock = {
        (resultString, error) -> Void in
        if error == nil {
            println(resultString)
        } else {
            println(error)
        }
    }
    
    init(val:UIImageView) {
        imgView = val
    }
    
    func httpGet(request: NSMutableURLRequest!, callback: (String,
        String?) -> Void) {
            var configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
            var session = NSURLSession(configuration: configuration,
                delegate: self,
                delegateQueue:NSOperationQueue.mainQueue())
            var task = session.dataTaskWithRequest(request){
                (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if error != nil {
                    callback("", error.localizedDescription)
                } else {
                    //This is only for text string data display
                    //var result = NSString(data: data, encoding:
                    //    NSASCIIStringEncoding)!
                    var result = "Get https data OK! Bytes: \(data.length) \n"
                    callback(result, nil)
                    
                    self.img = UIImage(data: data)
                    self.delegate?.didReceiveImgResults(self.imgView, img_data:self.img)
                    
                }
            }
            task.resume()
    }
    
    func URLSession(session: NSURLSession,
        didReceiveChallenge challenge:
        NSURLAuthenticationChallenge,
        completionHandler:
        (NSURLSessionAuthChallengeDisposition,
        NSURLCredential!) -> Void) {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust:
                    challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        willPerformHTTPRedirection response:
        NSHTTPURLResponse,
        newRequest request: NSURLRequest,
        completionHandler: (NSURLRequest!) -> Void) {
            var newRequest : NSURLRequest? = request
            println(newRequest?.description);
            completionHandler(newRequest)
    }
}