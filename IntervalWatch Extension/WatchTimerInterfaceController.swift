//
//  WatchTimerInterfaceController.swift
//  Intervals
//
//  Created by Scott Austin on 2/17/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

enum TimerMode: Int
{
    case Running = 0
    case Walking
    
    func description() -> String
    {
        switch self
        {
        case .Running:
            return "Running"
        case .Walking:
            return "Walking"
        }
    }
}

class WatchTimerInterfaceController: WKInterfaceController
{
    @IBOutlet weak var countdownTimer: WKInterfaceTimer!
    @IBOutlet weak var currentModeLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    var startTime: NSDate?
    var currentModeStartTime: NSDate?
    var pauseDate: NSDate?
    var userRunTime: NSTimeInterval?
    var userWalkTime: NSTimeInterval?
    
    var parentTimer: NSTimer?
    var elapsedTime: NSTimeInterval = 0
    
    var currentMode: TimerMode = .Running
    var isCounting = true
    var wakeFromSleep = false
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        userRunTime = (context as! [String : AnyObject])["runTime"] as? NSTimeInterval
        userWalkTime = (context as! [String: AnyObject])["walkTime"] as? NSTimeInterval
        
        countdownTimer.setDate(NSDate().dateByAddingTimeInterval(userRunTime!))
        parentTimer = NSTimer.scheduledTimerWithTimeInterval(userRunTime!, target: self, selector: "timerDone", userInfo: nil, repeats: false)
        
        
        currentModeLabel.setText(currentMode.description())
        
        startTime = NSDate()
        currentModeStartTime = startTime
        setStartButtonStyle()
        
        scheduleNotifications(userRunTime!)
    }
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if wakeFromSleep
        {
            wakeFromSleep = false
            
            //How long has it been, total?
            var totalTimeElapsed = NSDate().timeIntervalSinceDate(startTime!)
            
            //If we're paused, subtract paused time.
            if !isCounting
            {
                let pausedTime = NSDate().timeIntervalSinceDate(pauseDate!)
                totalTimeElapsed -= pausedTime
            }
            
            //Figure out which section we're in.
            let currentTimeElapsed = totalTimeElapsed % (userRunTime! + userWalkTime!)
            
            var timeRemaining: NSTimeInterval = 0
            //We're in a run cycle.
            if currentTimeElapsed < userRunTime!
            {
                timeRemaining = userRunTime! - currentTimeElapsed
                currentMode = .Running
            }
            //We're in a walk cycle
            else
            {
                timeRemaining = userWalkTime! - (currentTimeElapsed - userRunTime!)
                currentMode = .Walking
            }
            
            currentModeLabel.setText(currentMode.description())
            currentModeStartTime = NSDate().dateByAddingTimeInterval(-1 * timeRemaining)
            countdownTimer.setDate(NSDate().dateByAddingTimeInterval(timeRemaining))
            parentTimer = NSTimer.scheduledTimerWithTimeInterval(timeRemaining, target: self, selector: "timerDone", userInfo: nil, repeats: false)
            countdownTimer.start()
            setStartButtonStyle()

        }
    }
    
    override func didDeactivate()
    {
        parentTimer?.invalidate()
        wakeFromSleep = true
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func scheduleNotifications(timeRemaining: NSTimeInterval)
    {
        
        var currentlyRunning = true
        if currentMode != .Running
        {
            currentlyRunning = false
        }
        
        let messageDictionary: [String : AnyObject] = ["schedule" : true,
            "currentlyRunning" : currentlyRunning,
            "startDate": startTime!,
            "timeRemaining" : timeRemaining,
            "runTime" : userRunTime!,
            "walkTime" : userWalkTime!]

        if !WatchSessionManager.sharedManager.sendMessage(messageDictionary, replyHandler: nil, errorHandler: nil)
        {
            do
            {
                try WatchSessionManager.sharedManager.updateApplicationContext(messageDictionary)
            }
            catch
            {
                NSLog("\(error)")
            }
            
        }
        
    }
    
    func cancelNotifications()
    {
        let messageDictionary: [String:AnyObject] = ["schedule" : false]
        
        if !WatchSessionManager.sharedManager.sendMessage(messageDictionary, replyHandler: nil, errorHandler: nil)
        {
            do
            {
                try WatchSessionManager.sharedManager.updateApplicationContext(messageDictionary)
            }
            catch
            {
                NSLog("\(error)")
            }
            
        }
        
    }
    
    func setStartButtonStyle()
    {
        if isCounting
        {
            self.startButton.setTitle("Pause")
            self.startButton.setBackgroundColor(kRedColor)
        }
        else
        {
            self.startButton.setTitle("Resume")
            self.startButton.setBackgroundColor(kLightPurpleColor)
        }
    }
    
    @IBAction func pauseWasPressed(sender: WKInterfaceButton)
    {
        if isCounting
        {
            isCounting = false
            
            pauseDate = NSDate()
            elapsedTime += pauseDate!.timeIntervalSinceDate(currentModeStartTime!)
            
            parentTimer?.invalidate()
            self.countdownTimer.stop()
            self.cancelNotifications()
            setStartButtonStyle()
        }
        else
        {
            isCounting = true
            
            var currentModeTime: NSTimeInterval = 0
            if currentMode == .Running
            {
                currentModeTime = userRunTime!
            }
            else
            {
                currentModeTime = userWalkTime!
            }
            
            parentTimer = NSTimer.scheduledTimerWithTimeInterval(currentModeTime - elapsedTime, target: self, selector: "timerDone", userInfo: nil, repeats: false)
            countdownTimer.setDate(NSDate(timeIntervalSinceNow: currentModeTime - elapsedTime))
            countdownTimer.start()
            self.scheduleNotifications(userRunTime! - elapsedTime)
            setStartButtonStyle()
            
        }
    }
    
    func timerDone()
    {
        switch currentMode
        {
        case .Running:
            currentMode = .Walking
            currentModeStartTime = NSDate()
            countdownTimer.setDate(currentModeStartTime!.dateByAddingTimeInterval(userWalkTime!))
            parentTimer = NSTimer.scheduledTimerWithTimeInterval(userWalkTime!, target: self, selector: "timerDone", userInfo: nil, repeats: false)
        case .Walking:
            currentMode = .Running
            currentModeStartTime = NSDate()
            countdownTimer.setDate(currentModeStartTime!.dateByAddingTimeInterval(userRunTime!))
            parentTimer = NSTimer.scheduledTimerWithTimeInterval(userRunTime!, target: self, selector: "timerDone", userInfo: nil, repeats: false)
        }
        currentModeLabel.setText(currentMode.description())
        countdownTimer.start()
    }

}