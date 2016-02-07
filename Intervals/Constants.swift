//
//  Constants.swift
//  Intervals
//
//  Created by Scott Austin on 2/1/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation

let kDefaultRunTime: NSTimeInterval = 120
let kDefaultWalkTime: NSTimeInterval = 60

let kRunIntervalName = "RunInterval"
let kWalkIntervalName = "WalkInterval"
let kStartTime = "IntervalStartTime"
let kBackgroundAlert = "GoingToBackground"
let kLocalWalkNotificationRecieved = "LocalWalkNotification"
let kLocalRunNotificationRecieved = "LocalRunNotification"

/*
* Delay
* Runs x code after a delay
*/

func delay(delay:Double, closure:()->())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

/*
* Performs a countdown.
* Method performs countdownClosure at each second, and finalClosure when the countdown is finished.
*/
func countdown(seconds: Int,
    eachSecondAction countdownClosure: (timeIndex: Int) -> (),
    finalAction finalClosure: () -> ())
{
    for index in 1...(seconds - 1)
    {
        delay(Double(index))
            {
                countdownClosure(timeIndex: index)
        }
    }
    delay(Double(seconds))
        {
            finalClosure()
    }
}
