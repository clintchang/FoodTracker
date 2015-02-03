//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Clint on 1/28/15.
//  Copyright (c) 2015 Republic. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    var usdaItem:USDAItem?
    
    @IBOutlet weak var textView: UITextView!
    
    
    //as soon as our view is initialized we'll start the NSNotificationcenter
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if usdaItem != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func usdaItemDidComplete (notification: NSNotification) {
        
        println("usdaItemDidComplete in DetailviewController")
        //we can pull the USDAitem object because it was sent with the notification
        usdaItem = notification.object as? USDAItem
        
        if self.isViewLoaded() && self.view.window != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
        
    }
    
    @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem) {
        
        
    }
    
    func createAttributedString (usdaItem: USDAItem!) -> NSAttributedString {
        
        var itemAttributedString = NSMutableAttributedString()
        
        //first set up a paragraph style
        var centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = NSTextAlignment.Center
        centeredParagraphStyle.lineSpacing = 10.0
        var titleAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName : centeredParagraphStyle]
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
        itemAttributedString.appendAttributedString(titleString)
        return itemAttributedString
        
    }

}
