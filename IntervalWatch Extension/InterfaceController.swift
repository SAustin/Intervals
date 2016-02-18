//
//  InterfaceController.swift
//  IntervalWatch Extension
//
//  Created by Scott Austin on 2/17/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{

    @IBOutlet var runMinutesLabel: WKInterfacePicker?
    @IBOutlet var runSecondsLabel: WKInterfacePicker?
    @IBOutlet var walkMinutesLabel: WKInterfacePicker?
    @IBOutlet var walkSecondsLabel: WKInterfacePicker?
    
    var minuteOptions: [WKPickerItem]?
    var secondOptions: [WKPickerItem]?
    
    var userRunTime: NSTimeInterval = kDefaultRunTime
    var userWalkTime: NSTimeInterval = kDefaultWalkTime
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        createPickerArrays()
        
        runMinutesLabel?.setItems(minuteOptions)
        runMinutesLabel?.setSelectedItemIndex(2)
        walkMinutesLabel?.setItems(minuteOptions)
        walkMinutesLabel?.setSelectedItemIndex(1)
        runSecondsLabel?.setItems(secondOptions)
        walkSecondsLabel?.setItems(secondOptions)
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
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject?
    {
        switch segueIdentifier
        {
        case "startRunningSegue":
            return [userRunTime, userWalkTime]
        default:
            return nil
        }
    }
    
    func createPickerArrays()
    {
        self.minuteOptions = []
        self.secondOptions = []
        for index in 0...20
        {
            let item = WKPickerItem()
            item.title = "\(index)"
            self.minuteOptions?.append(item)
        }
        for index in 0...59
        {
            let item = WKPickerItem()
            item.title = index < 10 ? "0\(index)" : "\(index)"
            self.secondOptions?.append(item)
        }
    }

    @IBAction func runMinutePicked(index: Int)
    {
        let currentRunMinutes = Double(floor(userRunTime / 60))
        userRunTime = userRunTime - (60 * currentRunMinutes) + (Double(index) * 60)
    }

    @IBAction func runSecondPicked(index: Int)
    {
        let currentRunSeconds = userRunTime % 60
        userRunTime = userRunTime - currentRunSeconds + Double(index)
    }

    @IBAction func walknMinutePicked(index: Int)
    {
        let currentWalkMinutes = Double(floor(userWalkTime / 60))
        userWalkTime = userWalkTime - (60 * currentWalkMinutes) + (Double(index) * 60)
    }

    @IBAction func walkSecondPicked(index: Int)
    {
        let currentWalkSeconds = userWalkTime % 60
        userWalkTime = userWalkTime - currentWalkSeconds + Double(index)
    }

}
