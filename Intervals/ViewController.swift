//
//  ViewController.swift
//  Intervals
//
//  Created by Scott Austin on 1/8/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

//TODO: Fix weird animation issue on reset.
//TODO: Add running/walking status label
//TODO: Support running in the background
//TODO: Partner watch app

import UIKit

class ViewController: UIViewController, TimerLabelDelegate
{

    var startTime: NSDate?
    var totalTime = 25200
    var runInterval = 180.0
    var walkInterval = 60.0
    var currentlyRunning = false
    
    @IBOutlet var runLabel: UILabel?
    @IBOutlet var walkLabel: UILabel?
    @IBOutlet var overallLabel: UILabel?
    @IBOutlet var startButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    
    @IBOutlet var runUserInputTextField: UITextField?
    @IBOutlet var walkUserInputTextField: UITextField?
    
    @IBOutlet var userInputGroup: UIStackView?
    @IBOutlet var timerGroup: UIStackView?
    
    var userRunTime: NSTimeInterval = kDefaultRunTime
    var userWalkTime: NSTimeInterval = kDefaultWalkTime

    var overallTimer: TimerLabel?
    var runTimer: TimerLabel?
    var walkTimer: TimerLabel?
    
    
    override func viewDidLoad()
    {
        //TODO: Make sure the re-loading is pulling correct times for run/walk and setting run/walk correctly.
        //TODO: Make a label to make it clear which interval you're on.
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var timeDifference: NSTimeInterval
        
        //If this exists, the app went to sleep while we were in a run. I think.
        if let startTime = NSUserDefaults.standardUserDefaults().valueForKey(kStartTime) as? NSDate
        {
            self.clearNotifications()
            
            if self.runTimer == nil
            {
                self.userRunTime = NSUserDefaults.standardUserDefaults().valueForKey(kRunIntervalName) as! Double
                self.userWalkTime = NSUserDefaults.standardUserDefaults().valueForKey(kWalkIntervalName) as! Double
                
                timeDifference = NSDate().timeIntervalSinceDate(startTime)
                
                let currentMode = timeDifference % (self.userRunTime + self.userWalkTime)
                
                self.runTimer = TimerLabel(label: self.runLabel, timerType: .Timer)
                self.runTimer?.timeFormat = "mm:ss"
                self.runTimer?.timerDelegate = self
                self.runTimer?.setCountDownTime(self.userRunTime)
                
                self.walkTimer = TimerLabel(label: self.walkLabel, timerType: .Timer)
                self.walkTimer?.timeFormat = "mm:ss"
                self.walkTimer?.timerDelegate = self
                self.walkTimer?.setCountDownTime(self.userWalkTime)
                
                self.overallTimer = TimerLabel(label: self.overallLabel, timerType: .Stopwatch)
                self.overallTimer?.timeFormat = "hh:mm:ss"
                self.overallTimer?.timerDelegate = self
                self.overallTimer?.setStopWatchTime(timeDifference)
                
                if currentMode < self.userRunTime
                {
                    self.currentlyRunning = true
                    self.runTimer?.setCountDownTime(timeDifference - Double(Int(timeDifference / (self.userRunTime + self.userWalkTime)) * Int(self.userRunTime * self.userWalkTime)))

                    self.runTimer?.start()
                }
                else
                {
                    self.currentlyRunning = false
                    self.walkTimer?.setCountDownTime(timeDifference - Double(Int(timeDifference / (self.userRunTime + self.userWalkTime)) * Int(self.userRunTime * self.userWalkTime)))
                    
                    self.walkTimer?.start()
                }
                self.overallTimer?.start()
                self.startButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)

            }
        }
        else
        {
            self.runTimer = TimerLabel(label: self.runLabel, timerType: .Timer)
            self.runTimer?.timeFormat = "mm:ss"
            self.runTimer?.timerDelegate = self
            self.runTimer?.setCountDownTime(self.userRunTime)
            
            self.walkTimer = TimerLabel(label: self.walkLabel, timerType: .Timer)
            self.walkTimer?.timeFormat = "mm:ss"
            self.walkTimer?.timerDelegate = self
            self.walkTimer?.setCountDownTime(self.userWalkTime)
            
            self.overallTimer = TimerLabel(label: self.overallLabel, timerType: .Stopwatch)
            self.overallTimer?.timeFormat = "hh:mm:ss"
            self.overallTimer?.timerDelegate = self
            
            self.resetButton?.hidden = true
            
            self.timerGroup?.hidden = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scheduleAllNotifications", name: kBackgroundAlert, object: nil)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startWasPressed()
    {
        //If we've already pushed start...
        if self.overallTimer!.counting
        {
            self.overallTimer?.pause()
            self.runTimer?.pause()
            self.walkTimer?.pause()
            
            self.startButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
        }
        else
        {
            UIView.animateWithDuration(0.5)
            {
                self.timerGroup?.hidden = false
                self.userInputGroup?.hidden = true
                self.resetButton?.hidden = false
            }
            
            NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: kStartTime)
            NSUserDefaults.standardUserDefaults().setValue(self.userRunTime, forKey: kRunIntervalName)
            NSUserDefaults.standardUserDefaults().setValue(self.userWalkTime, forKey: kWalkIntervalName)

            self.currentlyRunning = true
            self.overallTimer?.start()
            self.runTimer?.start()
            self.scheduleAllNotificationsFromNow()
            
            self.startButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)

        }
    }
    
    @IBAction func resetWasPressed(sender: UIButton)
    {
        if self.overallTimer!.counting
        {
            self.startButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
        }
        
        self.overallTimer?.pause()
        self.runTimer?.pause()
        self.walkTimer?.pause()
        
        self.overallTimer?.reset()
        self.runTimer?.reset()
        self.walkTimer?.reset()
        
        self.clearNotifications()
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kStartTime)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kRunIntervalName)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kWalkIntervalName)

        
        UIView.animateWithDuration(0.5)
        {
            self.timerGroup?.hidden = true
            self.userInputGroup?.hidden = false
            self.resetButton?.hidden = true
        }

    }
    
    func scheduleAllNotificationsFromNow()
    {
        var timeFromNow = self.currentlyRunning ? self.runTimer!.getTimeRemaining() : self.walkTimer!.getTimeRemaining()
        
        for _ in 0...64
        {
            self.scheduleNotifications(timeFromNow, runReminder: self.currentlyRunning)
            timeFromNow += self.currentlyRunning ? self.userWalkTime : self.userRunTime
            self.scheduleNotifications(timeFromNow, runReminder: !self.currentlyRunning)
            timeFromNow += self.currentlyRunning ? self.userRunTime : self.userWalkTime
        }
    }

    func scheduleNotifications(timeFromNow: NSTimeInterval, runReminder: Bool)
    {
        //Schedule reminders
        let notification = UILocalNotification()
        
        if runReminder
        {
            notification.alertTitle = "Start Running!"
            notification.alertBody = "Begin running segment!"
        }
        else
        {
            notification.alertTitle = "Start Walking!"
            notification.alertBody = "Begin walking segment!"
        }
        
        
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = NSDate().dateByAddingTimeInterval(timeFromNow)
        notification.category = "IntervalReminder"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func clearNotifications()
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    //MARK: - UITextFields
    @IBAction func runTimeWasUpdated(sender: UITextField)
    {
        self.userRunTime = NSTimeInterval((sender.text! as NSString).doubleValue * 60)
        self.runTimer?.setCountDownTime(self.userRunTime)
    }
    
    @IBAction func walkTimeWasUpdated(sender: UITextField)
    {
        self.userWalkTime = NSTimeInterval((sender.text! as NSString).doubleValue * 60)
        self.walkTimer?.setCountDownTime(self.userWalkTime)
    }
    
    //MARK: - Timer Delegate
    
    func timerLabel(timerLabel: TimerLabel, countingTo time: NSTimeInterval, timerType: TimerLabelType)
    {
        
    }
    
    func timerLabel(timerLabel: TimerLabel, customTextToDisplayAtTime time: NSTimeInterval) -> String?
    {
        return nil
    }
    
    func timerLabel(timerLabel: TimerLabel, finishedCountDownTimerWithTime countTime: NSTimeInterval)
    {
        if timerLabel == self.runTimer
        {
            self.walkTimer?.start()
            self.currentlyRunning = false
            self.runTimer?.reset()
            
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kStartTime)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kRunIntervalName)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kWalkIntervalName)
            
            self.runTimer?.setCountDownTime(self.userRunTime)
            
//            let alert = UIAlertController(title: "Switch!", message: "Start walking!", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//            
//            self.presentViewController(alert, animated: true)
//            {
//                delay(3)
//                {
//                    alert.dismissViewControllerAnimated(true, completion: nil)
//                }
//            }
        }
        else if timerLabel == self.walkTimer
        {
            self.runTimer?.start()
            self.currentlyRunning = true
            self.walkTimer?.reset()
            self.walkTimer?.setCountDownTime(self.userWalkTime)

        }
    }
    
    @IBAction func viewTapped(sender: AnyObject)
    {
        self.walkUserInputTextField?.resignFirstResponder()
        self.runUserInputTextField?.resignFirstResponder()
    }

    
}

