//
//  WebViewController.swift
//  EvilNotes
//
//  Created by Sarahí López on 9/29/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView : UIWebView!
    
    var webUrl : URL!
    
    override func viewDidLoad() {
        webView.delegate = self
        
        webView.loadRequest(URLRequest(url: webUrl))
    }
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension WebViewController: UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Empezó")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Terminó")
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}
