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

        print("getCurrentContextValue(): key: \(key); activityIdent: \(activityIdent)")

        rlock.lock()

        guard let context = contextMap[activityIdent] ?? contextMap[parentIdent] else {
            rlock.unlock()
            return nil
        }

        contextValue = context[key.rawValue]

        print("getCurrentContextValue(): contextValue: \(contextValue!)")

        rlock.unlock()

        return contextValue
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()

        print("setCurrentContextValue(): activityIdent: \(activityIdent)")
        
        rlock.lock()

        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            let (activityIdent, scope) = TaskSupport.instance.createActivityContext()

            contextMap[activityIdent] = [String: AnyObject]()
            objectScope.setObject(scope, forKey: value)
        }

        contextMap[activityIdent]?[key.rawValue] = value

        rlock.unlock()
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        if let currentValue = contextMap[activityIdent]?[key.rawValue],
           currentValue === value {
            contextMap[activityIdent]?[key.rawValue] = nil

            print("removeContextValue() key: \(key.rawValue)")

            if contextMap[activityIdent]?.isEmpty ?? false {
                contextMap[activityIdent] = nil
            }
        }

        if let scope = objectScope.object(forKey: value) {
            TaskSupport.instance.leaveScope(scope: scope)
            objectScope.removeObject(forKey: value)
        }

        rlock.unlock()
    }
}
