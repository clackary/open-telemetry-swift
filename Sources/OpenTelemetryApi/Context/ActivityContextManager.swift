/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

import TaskSupport

class ActivityContextManager: ContextManager {
    static let instance = ActivityContextManager()

    let taskSupport = TaskSupport.instance
    
    let rlock = NSRecursiveLock()

    var objectScope = NSMapTable<AnyObject, ScopeElement>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    var contextMap = [task_identifier_t: [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        var parentIdent: os_activity_id_t = 0
        let activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, &parentIdent)
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
        var parentIdent: os_activity_id_t = 0
        var activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, &parentIdent)

        print("setCurrentContextValue(): OS_ACTIVITY_CURRENT: \(OS_ACTIVITY_CURRENT); parentIdent: \(parentIdent)")
        print("setCurrentContextValue(): activityIdent: \(activityIdent)")
        
        rlock.lock()

        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            var scope: os_activity_scope_state_s

            print("setCurrentContextValue(): key: \(key.rawValue)")
            
            (activityIdent, scope) = createActivityContext()

            contextMap[activityIdent] = [String: AnyObject]()
            objectScope.setObject(ScopeElement(scope: scope), forKey: value)
        }

        contextMap[activityIdent]?[key.rawValue] = value

        rlock.unlock()
    }

    func createActivityContext() -> (os_activity_id_t, os_activity_scope_state_s) {
        let dso = UnsafeMutableRawPointer(mutating: #dsohandle)
        let activity = _os_activity_create(dso, "ActivityContext", OS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT)
        let currentActivityId = os_activity_get_identifier(activity, nil)

        var activityState = os_activity_scope_state_s()

        print("createActivityContext(): activityState: \(activityState)")
        print("createActivityContext(): activity: \(activity); currentActivityId: \(currentActivityId); OS_ACTIVITY_CURRENT: \(OS_ACTIVITY_CURRENT)")
        
        os_activity_scope_enter(activity, &activityState)

        return (currentActivityId, activityState)
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, nil)

        print("removeContextValue(): activityIdent: \(activityIdent); OS_ACTIVITY_CURRENT: \(OS_ACTIVITY_CURRENT)")
        
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
            var scope = scope.scope
            
            os_activity_scope_leave(&scope)
            objectScope.removeObject(forKey: value)
        }

        rlock.unlock()
    }
}
