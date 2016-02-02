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
    
    @IBOutlet var runLabel: UILabel?
    @IBOutlet var walkLabel: UILabel?
    @IBOutlet var overallLabel: UILabel?
    @IBOutlet var startButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    
    @IBOutlet var runUserInputTextField: UITextField?
    @IBOutlet var walkUserInputTextField: UITextField?
    
    @IBOutlet var userInputGroup: UIStackView?
    @IBOutlet var timerGroup: UIStackView?
    
    var userRunTime = kDefaultRunTime
    var userWalkTime = kDefaultWalkTime

    var overallTimer: TimerLabel?
    var runTimer: TimerLabel?
    var walkTimer: TimerLabel?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
            
            self.overallTimer?.start()
            self.runTimer?.start()
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
        
        UIView.animateWithDuration(0.5)
        {
            self.timerGroup?.hidden = true
            self.userInputGroup?.hidden = false
            self.resetButton?.hidden = true
        }

    }

    func scheduleNotifications(timeFromNow: Int, runReminder: Bool)
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
        notification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(timeFromNow))
        notification.category = "IntervalReminder"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func clearNotifications()
    {
        //Cancel the existing local notification
        if let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        {
            for notification in scheduledLocalNotifications
            {
                if notification.alertTitle == "Start Running!" ||
                   notification.alertTitle == "Start Walking!"
                {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }

    }

    //MARK: - UITextFields
    @IBAction func runTimeWasUpdated(sender: UITextField)
    {
        self.userRunTime = NSTimeInterval((sender.text! as NSString).integerValue * 60)
        self.runTimer?.setCountDownTime(self.userRunTime)
    }
    
    @IBAction func walkTimeWasUpdated(sender: UITextField)
    {
        self.userWalkTime = NSTimeInterval((sender.text! as NSString).integerValue * 60)
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
            self.runTimer?.reset()
            self.runTimer?.setCountDownTime(self.userRunTime)
            
            let alert = UIAlertController(title: "Switch!", message: "Start walking!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true)
            {
                delay(3)
                {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        else if timerLabel == self.walkTimer
        {
            self.runTimer?.start()
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

