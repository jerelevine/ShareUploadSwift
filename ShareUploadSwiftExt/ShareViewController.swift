//
//  ShareViewController.swift
//  ShareUploadSwiftExt
//
//  Created by Jeremy Levine on 9/22/14.
//  Copyright (c) 2014 Jeremy Levine. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreGraphics

class ShareViewController: SLComposeServiceViewController, NSURLSessionDelegate, StackTableViewControllerDelegate {
    
    let kMaxCharactersAllowed = 100
    let kUploadURL = "http://requestb.in/1albjne1"
    let kURL = "URL"
    let kImage = "IMAGE"
    let kText = "TEXT"

    
    var image: UIImage?
    var url: NSURL?
    var type: NSString?
    var stack: NSString?
    
    var stackConfigurationItem: SLComposeSheetConfigurationItem?
    var array: NSArray = []

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        if let currentMessage = contentText {
            let currentMessageLength = countElements(currentMessage)
            charactersRemaining = kMaxCharactersAllowed - currentMessageLength
            
            if Int(charactersRemaining) < 0 {
                return false
            }
        }
        return true
    }
    
    override func presentationAnimationDidFinish() {
        // Only interested in the first item
        let extensionItem = extensionContext?.inputItems.first as NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as NSItemProvider
        
        self.type = self.kText

        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as NSString) {
            itemProvider.loadItemForTypeIdentifier(kUTTypeImage as NSString, options: nil) {
                (url, error) -> Void in
                let thisUrl = url as? NSURL;
                let thisData = NSData(contentsOfURL: thisUrl!)
                self.image = UIImage(data: thisData)
                self.type = self.kImage
            }
        }
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as NSString) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, UInt(0))) {
                itemProvider.loadItemForTypeIdentifier(kUTTypeURL as NSString, options: nil) {
                    (url, error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.url = url as? NSURL;
                        self.type = self.kURL
                    }
                }
            }
        }
        
        self.stack = self.stackConfigurationItem?.value
        
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let configName = "com.jeremyrosslevine.Share.BackgroundSessionConfig"
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(configName)
        // Extensions aren't allowed their own cache disk space. Need to share with application
        sessionConfig.sharedContainerIdentifier = "group.jeremyrosslevine.ShareUploadSwift"
        let session = NSURLSession(configuration: sessionConfig)
        
        var data: NSString? = ""
        
        if self.type == kImage {
            //data = UIImagePNGRepresentation(self.image).base64EncodedStringWithOptions(nil)
            data = UIImageJPEGRepresentation(self.image, 0.5).base64EncodedStringWithOptions(nil)

        }
        else if self.type == kURL {
            data = self.url?.absoluteString
        }
        
        addToDefaults(data, text: contentText, type: self.type!, stack: self.stack!)
        
        // Prepare the URL Request
        let request = urlRequestWithData(data!, text:contentText, type: self.type!, stack: self.stack!)
        
        // Create the task, and kick it off
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request!)
        
        task.resume()
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        extensionContext?.completeRequestReturningItems([AnyObject](), completionHandler: nil)
    }
    
    func urlRequestWithImage(image: UIImage?, text: String) -> NSURLRequest? {
        let url = NSURL.URLWithString(kUploadURL)
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        
        var jsonObject = NSMutableDictionary()
        jsonObject["text"] = text
        if let image = image {
            jsonObject["data"] = UIImagePNGRepresentation(image).base64EncodedStringWithOptions(nil)
        }
        println(jsonObject)
        
        // Create the JSON payload
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &jsonError)
        if (jsonData != nil) {
            request.HTTPBody = jsonData
        } else {
            if let error = jsonError {
                println("JSON Error: \(error.localizedDescription)")
            }
        }
        
        return request
    }
    
    func urlRequestWithData(data: NSString, text: String, type: String, stack: String) -> NSURLRequest? {
        
        let uploadURL = NSURL.URLWithString(kUploadURL)
        let request = NSMutableURLRequest(URL: uploadURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        
        var jsonObject = NSMutableDictionary()
        jsonObject["text"] = text
        jsonObject["type"] = type
        jsonObject["stack"] = stack;
        jsonObject["data"] = data//.substringToIndex(2000)
        println(data.length)
        
        //println(jsonObject)
        
        // Create the JSON payload
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: &jsonError)
        if (jsonData != nil) {
            request.HTTPBody = jsonData
        } else {
            if let error = jsonError {
                println("JSON Error: \(error.localizedDescription)")
            }
        }
        
        return request
    }
    
    func addToDefaults(data: NSString?, text: String, type: String, stack: String) {
        let mySharedDefaults = NSUserDefaults(suiteName:"group.jeremyrosslevine.ShareUploadSwift")
        mySharedDefaults.setObject(data, forKey:"data")
        mySharedDefaults.setObject(text, forKey:"text")
        mySharedDefaults.setObject(type, forKey:"type")
        mySharedDefaults.setObject(stack, forKey:"stack")

    }

    
    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here
    
        var configTable: StackTableViewController = StackTableViewController()
        configTable.size = self.preferredContentSize
        self.array = ["Cardbox", "My Favorite Photos", "My Favorite Websites", "My Favorite Videos"]
        configTable.optionNames = self.array.mutableCopy() as NSMutableArray
        configTable.delegate = self
        configTable.title = "Stack"
    
        self.stackConfigurationItem = SLComposeSheetConfigurationItem()
        self.stackConfigurationItem?.title = "Stack"
        self.stackConfigurationItem?.value = self.array[0] as NSString
        
    
        var weakSelf: ShareViewController = self
        self.stackConfigurationItem?.tapHandler = {
            var strongSelf: ShareViewController? = weakSelf
            if(strongSelf != nil) {
                strongSelf?.pushConfigurationViewController(configTable)
            }
        };
        
        return [self.stackConfigurationItem!]
    }

    
    func didSelectOptionAtIndexPath(indexPath: NSIndexPath) {
        self.stackConfigurationItem?.value = self.array[indexPath.row] as String
        self.popConfigurationViewController()
    }

}
