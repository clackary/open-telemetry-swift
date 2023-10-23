/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the Linux behavior required to employ activity contexts as offered by Apple's
// os_activity library. There is not a one-to-one mapping between the platform libraries employed;
// we do the best we can for Linux, using getcontext(3).

#if os(Linux)

import Foundation

import TaskSupport

class DefaultActivityContextManager: ContextManager {
    static let instance = DefaultActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [activity_id_t: [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, parentIdent) = TaskSupport.instance.getIdentifiers()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        print("DefaultActivityContextManager.getCurrentContextValue():")
        print("  key: \(key)")
        print("  activityIdent: \(activityIdent)")
        print("  parentIdent: \(parentIdent)")

        guard let context = contextMap[activityIdent] ?? contextMap[parentIdent] else {
            print("  contextMap: no item bound to activity: \(activityIdent); parent: \(parentIdent): returning nil")
            return nil
        }

        print("DefaultActivityContextManager.getCurrentContextValue(): found item: \(context); activity: \(activityIdent); parent: \(parentIdent)")

        return context[key.rawValue]
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityContext, _) = TaskSupport.instance.getIdentifiers()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        print("DefaultActivityContextManager.setCurrentContextValue():")
        print("  key: \(key)")
        print("  value: \(value)")
        print("  activityContext: \(activityContext)")

        if contextMap[activityContext] == nil || contextMap[activityContext]?[key.rawValue] != nil {
            let (activityContext, _) = TaskSupport.instance.createActivityContext()

            print("  contextMap: no item at context key: \(activityContext): initializing:")
            
            contextMap[activityContext] = [String: AnyObject]()
        }

        print("  contextMap: binding value: \(value) to context key: \(activityContext)")

        contextMap[activityContext]?[key.rawValue] = value
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityContext = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        print("DefaultActivityContextManager.removeCurrentContextValue():")
        print("  key: \(key)")
        print("  value: \(value)")
        print("  activityContext: \(activityContext)")

        if let currentValue = contextMap[activityContext]?[key.rawValue], currentValue === value {
            contextMap[activityContext]?[key.rawValue] = nil

            if contextMap[activityContext]?.isEmpty ?? false {
                print("  contextMap: removing item bound to context key: \(activityContext)")

                contextMap[activityContext] = nil
            }
        }
    }
}

#endif
