//
//  WatchTimerInterfaceController.swift
//  Intervals
//
//  Created by Scott Austin on 2/17/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import WatchKit

class WatchTimerInterfaceController: WKInterfaceController
{
    @IBOutlet weak var countdownTimer: WKInterfaceTimer!
    @IBOutlet weak var currentModeLabel: WKInterfaceLabel!
    
    var startTime: NSDate?
    var userRunTime: NSTimeInterval?
    var userWalkTime: NSTimeInterval?
    
    var parentTimer: NSTimer?
    
    var currentMode = "Running"
    var isCounting = true
    
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        userRunTime = (context as! [NSTimeInterval])[0]
        userWalkTime = (context as! [NSTimeInterval])[1]
        
        countdownTimer.setDate(NSDate().dateByAddingTimeInterval(userRunTime!))
        NSTimer.scheduledTimerWithTimeInterval(userRunTime, target: self, selector: "timerDone", userInfo: nil, repeats: false)
        
        
        currentModeLabel.setText(currentMode)
        
        startTime = NSDate()
    }
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func pauseWasPressed(sender: WKInterfaceButton)
    {
        if isCounting
        {
            
        }
        else
        {
            isCounting = true
            parentTimer = NSTimer.scheduledTimerWithTimeInterval(<#T##ti: NSTimeInterval##NSTimeInterval#>, target: <#T##AnyObject#>, selector: <#T##Selector#>, userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
        }
    }
    
    func timerDone()
    {
        if isCounting
        {
            
        }
    }

}