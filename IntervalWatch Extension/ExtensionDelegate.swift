//
//  ExtensionDelegate.swift
//  IntervalWatch Extension
//
//  Created by Scott Austin on 2/17/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching()
    {
        // Perform any final initialization of your application.
        WatchSessionManager.sharedManager.startSession()
    }

    func applicationDidBecomeActive()
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive()
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}

class WatchSessionManager: NSObject, WCSessionDelegate
{
    
    static let sharedManager = WatchSessionManager()
    private override init()
    {
        super.init()
    }
    
    private let session: WCSession = WCSession.defaultSession()
    
    func startSession()
    {
        session.delegate = self
        session.activateSession()
    }
    
    func sendMessage(message: [String : AnyObject], replyHandler: (([String : AnyObject]) -> Void)?, errorHandler: ((NSError) -> Void)?) -> Bool
    {
        if session.reachable
        {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
            return true
        }
        return false
    }
    
    func updateApplicationContext(applicationContext: [String: AnyObject]) throws
    {
        do
        {
            try session.updateApplicationContext(applicationContext)
        }
        catch
        {
            throw error
        }
    }
    
}

extension WatchSessionManager
{
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    {
        //update run state
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        //update run state
    }
}