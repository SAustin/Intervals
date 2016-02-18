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
import AVFoundation
import AudioToolbox
import WatchConnectivity

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
    @IBOutlet var runInputMinuteLabel: UILabel?
    @IBOutlet var walkInputMinuteLabel: UILabel?
    
    @IBOutlet var userInputGroup: UIStackView?
    @IBOutlet var timerGroup: UIStackView?
    
    @IBOutlet var currentModeLabel: UILabel?
    
    @IBOutlet var mainStackView: UIStackView?
    
    var userRunTime: NSTimeInterval = kDefaultRunTime
    var userWalkTime: NSTimeInterval = kDefaultWalkTime

    var overallTimer: TimerLabel?
    var runTimer: TimerLabel?
    var walkTimer: TimerLabel?
    
    var soundPlayer: AVAudioPlayer?
    
    var session: WCSession? {
        didSet {
            if let session = session
            {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    override func viewDidLoad()
    {
        //TODO: Make sure the re-loading is pulling correct times for run/walk and setting run/walk correctly.
        //TODO: Make a label to make it clear which interval you're on.
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //IS there a watch?
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
        }

        
        var timeDifference: NSTimeInterval
        
        let soundPath = NSBundle.mainBundle().pathForResource("beep-07", ofType: "wav")
        try! self.soundPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundPath!))
        self.soundPlayer!.prepareToPlay()

        
        //If this exists, the app went to sleep while we were in a run. I think.
        if let startTime = NSUserDefaults.standardUserDefaults().valueForKey(kStartTime) as? NSDate
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.clearNotifications()
            
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
                self.runLabel?.textColor = kMidGreenColor
                self.runUserInputTextField?.textColor = kMidGreenColor
                
                self.walkTimer = TimerLabel(label: self.walkLabel, timerType: .Timer)
                self.walkTimer?.timeFormat = "mm:ss"
                self.walkTimer?.timerDelegate = self
                self.walkTimer?.setCountDownTime(self.userWalkTime)
                self.walkLabel?.textColor = kMidBlueColor
                self.walkUserInputTextField?.textColor = kMidBlueColor
                
                self.overallTimer = TimerLabel(label: self.overallLabel, timerType: .Stopwatch)
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
                self.startButton?.setImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)

            }
        }
        else
        {
            self.runTimer = TimerLabel(label: self.runLabel, timerType: .Timer)
            self.runTimer?.timeFormat = "mm:ss"
            self.runTimer?.timerDelegate = self
            self.runTimer?.setCountDownTime(self.userRunTime)
            self.runLabel?.textColor = kMidGreenColor
            self.runUserInputTextField?.textColor = kMidGreenColor

            
            self.walkTimer = TimerLabel(label: self.walkLabel, timerType: .Timer)
            self.walkTimer?.timeFormat = "mm:ss"
            self.walkTimer?.timerDelegate = self
            self.walkTimer?.setCountDownTime(self.userWalkTime)
            self.walkLabel?.textColor = kMidBlueColor
            self.walkUserInputTextField?.textColor = kMidBlueColor

            
            self.overallTimer = TimerLabel(label: self.overallLabel, timerType: .Stopwatch)
            self.overallTimer?.timerDelegate = self
            
            self.hideTimers()
            self.currentModeLabel?.text = ""
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scheduleAllNotifications", name: kBackgroundAlert, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveRunNotification", name: kLocalRunNotificationRecieved, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveWalkNotification", name: kLocalWalkNotificationRecieved, object: nil)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didRecieveRunNotification()
    {
        self.currentModeLabel?.text = "Running"
        self.currentModeLabel?.textColor = kMidGreenColor
        
        self.runLabel?.alpha = 1.0
        self.walkLabel?.alpha = 0.3
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let alert = UIAlertController(title: "Switch!", message: "Start running!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true)
        {
            delay(3)
            {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        self.playBeeps(2)
    }
    
    func didRecieveWalkNotification()
    {
        self.currentModeLabel?.text = "Walking"
        self.currentModeLabel?.textColor = kMidBlueColor
        
        self.runLabel?.alpha = 0.3
        self.walkLabel?.alpha = 1.0

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let alert = UIAlertController(title: "Switch!", message: "Start walking!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true)
            {
                delay(3)
                    {
                        alert.dismissViewControllerAnimated(true, completion: nil)
                }
        }

        self.playBeeps(1)
    }
    
    @IBAction func startWasPressed()
    {
        //If we've already pushed start...
        if self.overallTimer!.counting
        {
            self.overallTimer?.pause()
            self.runTimer?.pause()
            self.walkTimer?.pause()
            
            self.currentModeLabel?.text = ""
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.clearNotifications()
            
            self.startButton?.setImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
            self.scheduleWatch(false)
        }
        else
        {
            self.currentlyRunning = true
            
            self.hideInputs()
            
            self.currentModeLabel?.text = "Running"
            self.currentModeLabel?.textColor = kMidGreenColor
            
            startTime = NSDate()
            NSUserDefaults.standardUserDefaults().setValue(startTime!, forKey: kStartTime)
            NSUserDefaults.standardUserDefaults().setValue(self.userRunTime, forKey: kRunIntervalName)
            NSUserDefaults.standardUserDefaults().setValue(self.userWalkTime, forKey: kWalkIntervalName)
            
            self.overallTimer?.start()
            self.runTimer?.start()
            
            let timeRemaining =  currentlyRunning ? self.runTimer!.getTimeRemaining() : self.walkTimer!.getTimeRemaining()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.scheduleAllNotificationsFromNow(self.currentlyRunning, timeRemaining: timeRemaining, runTime: userRunTime, walkTime: userWalkTime)

            self.scheduleWatch(true)
            self.startButton?.setImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)

        }
    }
    
    func scheduleWatch(shouldBeTiming: Bool)
    {
        if WCSession.isSupported()
        {
            var messageDictionary: [String : AnyObject]?
            
            if shouldBeTiming
            {
                let timeRemaining =  currentlyRunning ? self.runTimer!.getTimeRemaining() : self.walkTimer!.getTimeRemaining()
                
                messageDictionary = ["schedule" : true,
                    "currentlyRunning" : currentlyRunning,
                    "startDate": startTime!,
                    "timeRemaining" : timeRemaining,
                    "runTime" : userRunTime,
                    "walkTime" : userWalkTime]
            }
            else
            {
                messageDictionary = ["schedule" : false]
            }
            
            if session!.reachable
            {
                session!.sendMessage(messageDictionary!, replyHandler: nil, errorHandler: {
                    error in
                    NSLog("\(error)")
                })
            }
            else
            {
                do
                {
                    try session?.updateApplicationContext(messageDictionary!)
                }
                catch
                {
                    NSLog("\(error)")
                }
                
            }
            
        }

    }
    
    @IBAction func resetWasPressed(sender: UIButton)
    {
        if self.overallTimer!.counting
        {
            self.startButton?.setImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
        }
        
        self.currentModeLabel?.text = ""
        
        self.overallTimer?.pause()
        self.runTimer?.pause()
        self.walkTimer?.pause()
        
        self.overallTimer?.reset()
        self.overallLabel?.text = "0:00:00"
        self.runTimer?.reset()
        self.walkTimer?.reset()
        
        self.scheduleWatch(false)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.clearNotifications()
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kStartTime)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kRunIntervalName)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: kWalkIntervalName)

        self.hideTimers()

    }
    
    func hideInputs()
    {
        self.runLabel?.hidden = false
        self.walkLabel?.hidden = false
        
        if self.currentlyRunning
        {
            self.runLabel?.alpha = 1.0
            self.walkLabel?.alpha = 0.3
        }
        else
        {
            self.runLabel?.alpha = 0.3
            self.walkLabel?.alpha = 1.0
        }
        
        
        self.runUserInputTextField?.hidden = true
        self.runInputMinuteLabel?.hidden = true
        self.walkInputMinuteLabel?.hidden = true
        self.walkUserInputTextField?.hidden = true
        
        self.resetButton?.hidden = false
        
    }
    
    func hideTimers()
    {
        self.runUserInputTextField?.hidden = false
        self.runInputMinuteLabel?.hidden = false
        self.walkUserInputTextField?.hidden = false
        self.walkInputMinuteLabel?.hidden = false
        
        self.runLabel?.hidden = true
        self.walkLabel?.hidden = true
        
        self.resetButton?.hidden = true
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
    
    func playBeeps(numberOfBeeps: Int)
    {
        for index in 0...numberOfBeeps - 1
        {
            delay(Double(index)*0.2)
                {
                    self.soundPlayer?.play()
                    return
            }
        }
    }

    
}

extension ViewController: WCSessionDelegate
{
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        recievedWatchMessage(applicationContext)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    {
        recievedWatchMessage(message)
    }
    
    func recievedWatchMessage(message: [String : AnyObject])
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let scheduleNotifications = message["schedule"] as! Bool
        
        if scheduleNotifications
        {
            appDelegate.scheduleAllNotificationsFromNow(message["currentlyRunning"] as! Bool, timeRemaining: message["timeRemaining"] as! NSTimeInterval, runTime: message["runTime"] as! NSTimeInterval, walkTime: message["walkTime"] as! NSTimeInterval)
        }
        else
        {
            appDelegate.clearNotifications()
        }

    }
}

