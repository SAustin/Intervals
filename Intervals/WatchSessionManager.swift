//
//  WatchSessionManager.swift
//  Intervals
//
//  Created by Scott Austin on 2/19/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol MessageWasRecievedDelegate
{
    func newMessageWasRecieved(message: [String : AnyObject])
}

class WatchSessionManager: NSObject
{
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var messageReceievedDelegates = [MessageWasRecievedDelegate]()
    
    static let sharedManager = WatchSessionManager()
    
    private var validSession: WCSession?
    {
        if let session = session where session.paired && session.watchAppInstalled
        {
            return session
        }
        return nil
    }
    
    private var validReachableSession: WCSession?
    {
        if let session = validSession where session.reachable
        {
            return session
        }
        
        return nil
    }
    
    private override init()
    {
        super.init()
    }
    
    func startSession()
    {
        session?.delegate = self
        session?.activateSession()
    }
    
    // adds / removes dataSourceChangedDelegates from the array
    func addMessageRecievedDelegate<T where T: MessageWasRecievedDelegate, T: Equatable>(delegate: T)
    {
        messageReceievedDelegates.append(delegate)
    }
    
    func removeDataSourceChangedDelegate<T where T: MessageWasRecievedDelegate, T: Equatable>(delegate: T)
    {
        for (index, messageRecievedDelegate) in messageReceievedDelegates.enumerate()
        {
            if let messageRecievedDelegate = messageRecievedDelegate as? T where messageRecievedDelegate == delegate
            {
                messageReceievedDelegates.removeAtIndex(index)
                break
            }
        }
    }
    
    func sessionReachabilityDidChange(session: WCSession)
    {
        if session.reachable
        {
            //Continue with Interactive messaging
        }
        else
        {
            //Prompt user to unlock their device
        }
    }
}

extension WatchSessionManager
{
    func sendMessage(message: [String : AnyObject], replyHandler: (([String : AnyObject]) -> Void)?, errorHandler: ((NSError) -> Void)?) -> Bool
    {
        if let session = validReachableSession
        {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
            return true
        }
        
        return false
    }
    
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws
    {
        if let session = validSession
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
}

extension WatchSessionManager: WCSessionDelegate
{
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            [weak self] in
            self?.messageReceievedDelegates.forEach
            {
                $0.newMessageWasRecieved(message)
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        dispatch_async(dispatch_get_main_queue())
            {
                [weak self] in
                self?.messageReceievedDelegates.forEach
                    {
                        $0.newMessageWasRecieved(message)
                }
        }

    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        dispatch_async(dispatch_get_main_queue())
            {
                [weak self] in
                self?.messageReceievedDelegates.forEach
                    {
                        $0.newMessageWasRecieved(applicationContext)
                }
        }

    }
}