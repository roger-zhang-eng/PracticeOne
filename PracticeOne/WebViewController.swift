//
//  WebViewController.swift
//  PracticeOne
//
//  Created by Roger Zhang on 24/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var url: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if url != nil {
            let request = NSURLRequest(URL: url!)
            webView.loadRequest(request)
        }
            

        
    }
    
    @IBAction func WebStop(sender: UIBarButtonItem) {
        print("WebView stop loading")
        webView.stopLoading()
    }

    @IBAction func WebRefresh(sender: UIBarButtonItem) {
        print("WebView refresh loading")
        webView.reload()
    }
    
    @IBAction func WebRewind(sender: UIBarButtonItem) {
        print("WebView rewind loading")
        webView.goBack()
    }
    
    @IBAction func WebForward(sender: UIBarButtonItem) {
        print("WebView forward loading")
        webView.goForward()
        
    }
    
    
}
