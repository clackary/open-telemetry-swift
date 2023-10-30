/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the Linux behavior required to employ activity contexts as offered by Apple's
// os_activity library. There is not a one-to-one mapping between the platform libraries employed;
// we do the best we can for Linux.

#if os(Linux)

import Foundation

import TaskSupport

class LinuxActivityContextManager: ContextManager {
    static let instance = LinuxActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [activity_id_t: [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, parentIdent) = TaskSupport.instance.getIdentifiers()
        var contextValue: AnyObject?

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let context = contextMap[activityIdent] ?? contextMap[parentIdent] else {
            return nil
        }

        contextValue = context[key.rawValue]
        
        print("LinuxActivityContextManager.getCurrentContextValue(): found contextValue: \(contextValue)")

        return contextValue
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        // This code block makes absolutely no sense to me. Might be related to the use of MacOS activities, which
        // do not apply to Linux...

        /* 
        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            let (activityIdent, _) = TaskSupport.instance.createActivityContext()

            contextMap[activityIdent] = [String: AnyObject]()
        }
        */
        
        if contextMap[activityIdent] == nil {
            contextMap[activityIdent] = [String: AnyObject]()
        }

        print("LinuxActivityContextManager.setCurrentContextValue(): remembering \(value) for activityIdent: \(activityIdent)")

        contextMap[activityIdent]?[key.rawValue] = value

        print("    contextMap: \(contextMap)")
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()

        print("LinuxActivityContextManager.removeContextValue(): remove: \(value); key: \(key); id: \(activityIdent):")
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if let currentValue = contextMap[activityIdent]?[key.rawValue], currentValue === value {
            contextMap[activityIdent]?[key.rawValue] = nil

            print("    \(activityIdent) removed")

            if contextMap[activityIdent]?.isEmpty ?? false {
                contextMap[activityIdent] = nil
            }
        }
    }
}

#endif
