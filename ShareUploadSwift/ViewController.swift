//
//  ViewController.swift
//  ShareUploadSwift
//
//  Created by Jeremy Levine on 9/22/14.
//  Copyright (c) 2014 Jeremy Levine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let kURL = "URL"
    let kImage = "IMAGE"
    let kText = "TEXT"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let mySharedDefaults = NSUserDefaults(suiteName:"group.jeremyrosslevine.ShareUploadSwift")
        //println(mySharedDefaults.dictionaryRepresentation())
        
        var data: NSString? = nil
        var text: NSString? = nil
        var type: NSString? = nil

        
        
        if let tempData: NSString = mySharedDefaults.objectForKey("data") as? NSString {
            data = tempData
        }
        if let tempText: NSString = mySharedDefaults.objectForKey("text") as? NSString {
            text = tempText
        }
        if let tempType: NSString = mySharedDefaults.objectForKey("type") as? NSString {
            type = tempType
        }



        
        if type == self.kURL {
            let webView: UIWebView = UIWebView(frame: CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height/2))
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string: data!));
            webView.loadRequest(request)
            self.view.addSubview(webView);
        }
        else if type == self.kImage {
            let imageData = NSData(base64EncodedString: data!, options: nil)
            let image: UIImage = UIImage(data:imageData);
            let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height/2));
            imageView.image = image
            self.view.addSubview(imageView);
        }
        else if type == self.kText {
            
        }
        else {
            return
        }
        
        let label: UILabel = UILabel(frame: CGRectMake(10, self.view.frame.size.height/2+75, self.view.frame.size.width-20, 100));
        label.text = text;
        label.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(label)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

