//
//  TimerLabel.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/25/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

/**********************************************
 Delegate Methods
 
 - timerLabel:finshedCountDownTimerWithTimeWithTime:
 ** TimerLabel Delegate method for finish of countdown timer
 - timerLabel:countingTo:timertype:
 ** TimerLabel Delegate method for monitering the current counting progress
 
 - timerlabel:customTextToDisplayAtTime:
 ** TimerLabel Delegate method for overriding the text displaying at the time, implement this for your very custom display formmat. Return nil if you don't want to use this method.
 **********************************************/

enum TimerLabelType: Int
{
    case Stopwatch = 0
    case Timer
}

protocol TimerLabelDelegate
{
    func timerLabel(timerLabel: TimerLabel, finishedCountDownTimerWithTime countTime: NSTimeInterval);
    func timerLabel(timerLabel: TimerLabel, countingTo time:NSTimeInterval, timerType: TimerLabelType);
    func timerLabel(timerLabel: TimerLabel, customTextToDisplayAtTime time:NSTimeInterval) -> String?;
}

class TimerLabel: UILabel
{
    let kTimeHourFormatReplace: String = "!!!*"
    let kDefaultFireIntervalNormal = 0.1
    let kDefaultFireIntervalHighUse = 0.01
    
    
    /*Delegate for finish of countdown timer */
    var timerDelegate: TimerLabelDelegate?
    
    /*Time format wish to display in label*/
    var timeFormat: String = "HH:mm:ss"
    {
        didSet
        {
            if self.timeFormat.characters.count != 0
            {
                self.dateFormatter.dateFormat = timeFormat
            }
            
            self.updateLabel()

        }
    }
    
    /*Target label obejct, default self if you do not initWithLabel nor set*/
    var timeLabel: UILabel?
    
    /*Used for replace text in range */
    var textRange: NSRange?
    var attributedDictionaryForTextInRange: [String: AnyObject]?
    
    /*Type to choose from stopwatch or timer*/
    var timerType: TimerLabelType? = .Stopwatch
    
    /*Is The Timer Running?*/
    var counting: Bool = false
    
    /*Do you want to reset the Timer after countdown?*/
    var resetTimerAfterFinish: Bool = true
    
    /*Do you want the timer to count beyond the HH limit from 0-23 e.g. 25:23:12 (HH:mm:ss) */
    var shouldCountBeyondHHLimit: Bool = true
    {
        didSet
        {
            self.updateLabel()
        }
    }
    
    var timeUserValue: NSTimeInterval = 0
    var startCountDate: NSDate?
    var pausedTime: NSDate?
    var date1970: NSDate = NSDate(timeIntervalSince1970: 0)
    var timeToCountOff: NSDate?
    
    var timer: NSTimer?
    var dateFormatter: NSDateFormatter
    
    var endBlock: ((NSTimeInterval) -> ())?
    
    /*--------designated Initializer*/
    init(frame: CGRect, label: UILabel?,  theTimerType: TimerLabelType?)
    {
        timeLabel = label

        if let _ = timerType
        {
            timerType = theTimerType
        }
        
        dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = self.timeFormat

        super.init(frame: frame)

        if let _ = label
        {
            timeLabel = label
        }
        else
        {
            timeLabel = self
        }
        
        self.setup()
    }

    /*--------Init methods to choose*/
    convenience init(timerType: TimerLabelType)
    {
        self.init(frame:CGRectZero, label: nil, theTimerType: timerType)
    }

    convenience init(label: UILabel?, timerType: TimerLabelType)
    {
        self.init(frame: CGRectZero, label: label, theTimerType: timerType)
    }
    
    convenience init(label: UILabel?)
    {
        self.init(frame: CGRectZero, label: label, theTimerType: nil)
    }

    override convenience init(frame: CGRect)
    {
        self.init(frame: frame, label: nil, theTimerType: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = self.timeFormat

        super.init(coder: aDecoder)
        self.setup()
    }

    /*--------Setter methods*/
    func setCountDownTime(time: NSTimeInterval)
    {
        self.timeUserValue = (time < 0) ? 0 : time
        self.timeToCountOff = self.date1970.dateByAddingTimeInterval(self.timeUserValue)
        self.updateLabel()
    }
    
    func setStopWatchTime(time: NSTimeInterval)
    {
        self.timeUserValue = (time < 0) ? 0 : time
        
        if self.timeUserValue > 0
        {
            self.startCountDate = NSDate().dateByAddingTimeInterval(-1 * self.timeUserValue)
            self.pausedTime = NSDate()
            self.updateLabel()
        }
    }
    
    func setCountDownToDate(date: NSDate)
    {
        let timeLeft = date.timeIntervalSinceDate(NSDate())
        if timeLeft > 0
        {
            self.timeUserValue = timeLeft
            self.timeToCountOff = self.date1970.dateByAddingTimeInterval(timeLeft)
        }
        else
        {
            timeUserValue = 0
            self.timeToCountOff = self.date1970.dateByAddingTimeInterval(0)
        }
        self.updateLabel()
    }
    
    func addTimeCountedByTime(time: NSTimeInterval)
    {
        switch self.timerType!
        {
        case .Timer:
            self.setCountDownTime(time + self.timeUserValue)
        case .Stopwatch:
            let newStartDate = self.startCountDate?.dateByAddingTimeInterval(-1 * time)
            if NSDate().timeIntervalSinceDate(newStartDate!) >= 0
            {
                self.startCountDate = NSDate()
            }
            else
            {
                self.startCountDate = newStartDate
            }
        }
        
        self.updateLabel()
    }
    
    /*--------Getter methods*/
    func getTimeLabel() -> UILabel
    {
        if self.timeLabel == nil
        {
            return self
        }
        else
        {
            return self.timeLabel!
        }
        
    }
    
    func getTimeCounted() -> NSTimeInterval
    {
        if self.startCountDate == nil
        {
            return 0
        }
        var countedTime = NSDate().timeIntervalSinceDate(self.startCountDate!)
        
        if let pausedTime = self.pausedTime
        {
            let pauseCountedTime = NSDate().timeIntervalSinceDate(pausedTime)
            countedTime -= pauseCountedTime
        }
        
        return countedTime
    }
    
    func getTimeRemaining() -> NSTimeInterval
    {
        if self.timerType == .Timer
        {
            return self.timeUserValue - self.getTimeCounted()
        }
        
        return 0
    }
    
    func getCountDownTime() -> NSTimeInterval
    {
        if self.timerType == .Timer
        {
            return self.timeUserValue
        }
        
        return 0
    }

    //MARK: - Timer Control Method
    func start()
    {
        if let _ = self.timer
        {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        if (self.timeFormat.rangeOfString("SS") != nil)
        {
            self.timer = NSTimer(timeInterval: kDefaultFireIntervalHighUse, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }
        else
        {
            self.timer = NSTimer(timeInterval: kDefaultFireIntervalNormal, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        }

        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        
        if(self.startCountDate == nil)
        {
            startCountDate = NSDate()
            
            if (self.timerType == .Stopwatch && self.timeUserValue > 0)
            {
                startCountDate = self.startCountDate?.dateByAddingTimeInterval(-1 * self.timeUserValue)
            }
        }
        
        if let pausedTime = self.pausedTime
        {
            let countedTime = pausedTime.timeIntervalSinceDate(self.startCountDate!)
            self.startCountDate! = NSDate().dateByAddingTimeInterval(-1 * countedTime)
            self.pausedTime = nil
        }
        
        self.counting = true;
        self.timer!.fire()
    }
    
    func start(closure:(NSTimeInterval) -> ())
    {
        self.endBlock = closure
        self.start()
    }
    
    func pause()
    {
        if self.counting
        {
            self.timer?.invalidate()
            self.timer = nil
            self.counting = false
            self.pausedTime = NSDate()
        }
    }
    
    func reset()
    {
        self.pausedTime = nil
        if self.timerType == .Stopwatch
        {
            self.timeUserValue = 0
        }
        self.startCountDate = (self.counting) ? NSDate() : nil
    }
    
    func setup()
    {
        self.updateLabel()
    }
    
    func updateLabel()
    {
        var timeDiff: NSTimeInterval
        if let startDate = self.startCountDate
        {
            timeDiff = NSDate().timeIntervalSinceDate(startDate)
        }
        else
        {
            timeDiff = 0
        }
        var timeToShow = NSDate()
        var timerEnded = false
        
        switch self.timerType!
        {
        /***MZTimerLabelTypeStopWatch Logic***/
        case .Stopwatch:
            if self.counting
            {
                timeToShow = self.date1970.dateByAddingTimeInterval(timeDiff)
            }
            else
            {
                if let _ = self.startCountDate
                {
                    timeToShow = self.date1970.dateByAddingTimeInterval(timeDiff)
                }
                else
                {
                    timeToShow = self.date1970.dateByAddingTimeInterval(0)
                }
            }
        /***MZTimerLabelTypeTimer Logic***/
        case .Timer:
            if self.counting
            {
                let timeLeft = self.timeUserValue - timeDiff
                self.timerDelegate?.timerLabel(self, countingTo: timeLeft, timerType: self.timerType!)
                
                if timeDiff >= self.timeUserValue
                {
                    self.pause()
                    timeToShow = self.date1970.dateByAddingTimeInterval(0)
                    self.startCountDate = nil
                    timerEnded = true
                }
                else
                {
                    timeToShow = self.timeToCountOff!.dateByAddingTimeInterval(timeDiff * -1)
                }
            }
            else
            {
                if let _ = self.timeToCountOff
                {
                    timeToShow = self.timeToCountOff!
                }
                else
                {
                    timeToShow = NSDate()
                }
                
            }
            
        }
        
        var atTime: NSTimeInterval
        switch self.timerType!
        {
        case .Stopwatch:
            atTime = timeDiff
        case .Timer:
            if self.timeUserValue - timeDiff < 0
            {
                atTime = 0
            }
            else
            {
                atTime = self.timeUserValue - timeDiff
            }
        }
        
        let customText = self.timerDelegate?.timerLabel(self, customTextToDisplayAtTime: atTime)
        if let text = customText
        {
            self.timeLabel?.text = text
        }
        else
        {
            self.timeLabel?.text = self.dateFormatter.stringFromDate(timeToShow)
            
            if self.shouldCountBeyondHHLimit
            {
                let originalTimeFormat = self.timeFormat
                var beyondFormat = self.timeFormat.stringByReplacingOccurrencesOfString("HH", withString: kTimeHourFormatReplace)
                beyondFormat = beyondFormat.stringByReplacingOccurrencesOfString("H", withString: kTimeHourFormatReplace)
                self.dateFormatter.dateFormat = beyondFormat
                
                let hours = self.timerType! == .Stopwatch ? Int(self.getTimeCounted() / 3600) : Int(self.getTimeRemaining() / 3600)
                let formattedDate = self.dateFormatter.stringFromDate(timeToShow)
                let beyondDate = formattedDate.stringByReplacingOccurrencesOfString(kTimeHourFormatReplace, withString: "\(hours)")
                
                self.timeLabel?.text = beyondDate
                self.dateFormatter.dateFormat = originalTimeFormat
            }
            else
            {
                if self.textRange?.length > 0
                {
                    if let dictionary = self.attributedDictionaryForTextInRange
                    {
                        let attrTextInRange = NSAttributedString(string: self.dateFormatter.stringFromDate(timeToShow), attributes: dictionary)
                        let attributedString = NSMutableAttributedString(string: self.text!)
                        attributedString.replaceCharactersInRange(self.textRange!, withAttributedString: attrTextInRange)
                        self.timeLabel?.attributedText = attributedString
                    }
                    else
                    {
                        let labelText = (self.text! as NSString).stringByReplacingCharactersInRange(self.textRange!, withString: (self.dateFormatter.stringFromDate(timeToShow)))
                        self.timeLabel?.text = labelText
                    }

                }
                else
                {
                    self.timeLabel?.text = self.dateFormatter.stringFromDate(timeToShow)
                }
            }
        }
        
        
        if timerEnded
        {
            self.timerDelegate?.timerLabel(self, finishedCountDownTimerWithTime: self.timeUserValue)
            
            if let endBlock = self.endBlock
            {
                endBlock(self.timeUserValue)
            }
            
            if self.resetTimerAfterFinish
            {
                self.reset()
            }
        }
    }
}