/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

import TaskSupport

class ActivityContextManager: ContextManager {
    static let instance = ActivityContextManager()

    let rlock = NSRecursiveLock()

    var objectScope = NSMapTable<AnyObject, ScopeElement>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    var contextMap = [activity_id_t: [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, parentIdent) = TaskSupport.instance.getIdentifiers()
        var contextValue: AnyObject?

        print("ActivityContextManager.getCurrentContextValue():")
        print("  key: \(key)")
        print("  activityIdent: \(activityIdent)")
        print("  parentIdent: \(parentIdent)")

        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        guard let context = contextMap[activityIdent] ?? contextMap[parentIdent] else {
            print("  contextMap: no item for activityIdent: returning nil")
            
            return nil
        }

        print("  context: \(context)")

        contextValue = context[key.rawValue]

        return contextValue
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()

        print("ActivityContextManager.setCurrentContextValue():")
        print("  key: \(key)")
        print("  value: \(value)")
        print("  activityIdent: \(activityIdent)")
        
        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            let (activityIdent, scope) = TaskSupport.instance.createActivityContext()

            print("ActivityContextManager.setCurrentContextValue(): context map: no item at index: \(activityIdent): initializing:")
            print("  scope: \(scope)")

            contextMap[activityIdent] = [String: AnyObject]()
            objectScope.setObject(scope, forKey: value)
        }

        contextMap[activityIdent]?[key.rawValue] = value
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        print("ActivityContextManager.removeContextValue():")
        print("  key: \(key)")
        print("  value: \(value)")
        print("  activityIdent: \(activityIdent)")

        defer {
            rlock.unlock()
        }
        
        if let currentValue = contextMap[activityIdent]?[key.rawValue],
           currentValue === value {
            print("  contextMap[activityIdent]: \(currentValue)")
            
            contextMap[activityIdent]?[key.rawValue] = nil

            if contextMap[activityIdent]?.isEmpty ?? false {
                contextMap[activityIdent] = nil
            }
        }

        if let scope = objectScope.object(forKey: value) {
            print("  leaving scope: \(scope)")
            
            TaskSupport.instance.leaveScope(scope: scope)
            objectScope.removeObject(forKey: value)
        }
    }
}
