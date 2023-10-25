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

struct stack {
    var _stack: [AnyObject] = []

    mutating func push(_ item: AnyObject) {
        _stack.append(item)
    }

    mutating func pop() -> AnyObject? {
        if (_stack.isEmpty) {
            return nil
        }
            
        return _stack.removeLast()
    }

    mutating func remove(_ item: AnyObject) {
        if let index = _stack.firstIndex(of: item) {
            _stack.remove(at: index)
        }
    }
}

class DefaultActivityContextManager: ContextManager {
    static let instance = DefaultActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [activity_id_t: [String: stack]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let contextStack = contextMap[activityIdent] else {
            print("LinuxActivityContextManager.getCurrentContextValue(): context map has no stack bound to identifier: \(activityIdent); returning nil")
            return nil
        }

        guard let item = contextStack[key.rawValue].pop() else {
            print("LinuxActivityContextManager.getCurrentContextValue(): context stack is empty")
            return nil
        }

        print("LinuxActivityContextManager.getCurrentContextValue(): found item: \(item) on stack.")

        return item
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityContext, _) = TaskSupport.instance.getIdentifiers()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[activityContext] == nil || contextMap[activityContext]?[key.rawValue] != nil {
            let (activityContext, _) = TaskSupport.instance.createActivityContext()

            contextMap[activityContext] = [String: stack]()
        }

        print("  contextMap: pushing value \(value) onto stack for key: \(activityContext)")

        contextMap[activityContext]?[key.rawValue].push(value)
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityContext = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        if let currentValue = contextMap[activityContext]?[key.rawValue], currentValue === value {
            contextMap[activityContext]?[key.rawValue].remove(value)
        }
    }
}

#endif
