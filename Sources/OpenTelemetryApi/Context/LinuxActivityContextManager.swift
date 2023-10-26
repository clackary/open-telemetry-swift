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

class stack {
    var _stack = [AnyObject]()

    func push(_ item: AnyObject) {
        _stack.append(item)
    }

    func pop() -> AnyObject? {
        if (_stack.isEmpty) {
            return nil
        }
            
        return _stack.removeLast()
    }

    func remove(_ item: AnyObject) {
        _stack.removeAll(where: { item === $0 })
    }
}

class LinuxActivityContextManager: ContextManager {
    static let instance = LinuxActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [activity_id_t: [String: stack]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let contextStack = contextMap[activityIdent] else {
            return nil
        }

        guard let map = contextStack[key.rawValue] else {
            return nil
        }

        guard let item = map.pop() else {
            return nil
        }

        print("LinuxActivityContextManager.getCurrentContextValue(): found item: \(item) on stack.")

        return item
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            let (activityIdent, _) = TaskSupport.instance.createActivityContext()

            contextMap[activityIdent] = [String: stack]()
        }

        print("LinuxActivityContextManager.setCurrentContextValue(): pushing \(value) onto stack for key: \(activityIdent)")

        contextMap[activityIdent]?[key.rawValue]?.push(value)
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()

        print("LinuxActivityContextManager.removeContextValue(): remove: \(value); key: \(key); id: \(activityIdent)")
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let contextStack = contextMap[activityIdent] else {
            return
        }

        guard let map = contextStack[key.rawValue] else {
            return
        }

        map.remove(value)
    }
}

#endif
