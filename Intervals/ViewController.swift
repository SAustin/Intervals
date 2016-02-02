//
//  ViewController.swift
//  Intervals
//
//  Created by Scott Austin on 1/8/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var startTime: NSDate?
    var totalTime = 25200
    var runInterval = 180.0
    var walkInterval = 60.0
    
    @IBOutlet var runLabel: UILabel!
    @IBOutlet var walkLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deceaseWalkInterval(sender: UIButton)
    {
        self.walkInterval -= 60.0
        self.updateWalkLabel()
    }
    
    @IBAction func increaseWalkInterval(sender: UIButton)
    {
        self.walkInterval += 60.0
        self.updateWalkLabel()
    }
    
    @IBAction func decreaseRunInterval(sender: UIButton)
    {
        self.runInterval -= 60.0
        self.updateRunLabel()
    }
    
    @IBAction func increaseRunInterval(sender: UIButton)
    {
        self.runInterval += 60
        self.updateRunLabel()
    }
    
    func updateRunLabel()
    {
        let minutes = Int(self.runInterval / 60.0)
        let seconds = Int(self.runInterval % 60)
        
        var minutesString = "\(minutes)"
        if minutesString.characters.count == 1
        {
            minutesString = "0" + minutesString
        }
        var secondsString = "\(seconds)"
        if secondsString.characters.count == 1
        {
            secondsString = "0" + secondsString
        }
        
        self.runLabel.text = "\(minutesString):\(secondsString)"
    }
    
    func updateWalkLabel()
    {
        let minutes = Int(self.walkInterval / 60.0)
        let seconds = Int(self.walkInterval % 60)
        
        var minutesString = "\(minutes)"
        if minutesString.characters.count == 1
        {
            minutesString = "0" + minutesString
        }
        var secondsString = "\(seconds)"
        if secondsString.characters.count == 1
        {
            secondsString = "0" + secondsString
        }
        
        self.walkLabel.text = "\(minutesString):\(secondsString)"
    }

    
    @IBAction func startWasPressed()
    {
        if self.startButton.titleLabel?.text == "Start"
        {
            var index = 0
            while index < self.totalTime
            {
                self.scheduleNotifications(index, runReminder: true)
                index += Int(self.runInterval)
                self.scheduleNotifications(index, runReminder: false)
                index += Int(self.walkInterval)
            }
            self.startButton.titleLabel?.text = "End"
        }
        else
        {
            self.clearNotifications()
            self.startButton.titleLabel?.text = "Start"
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

}

