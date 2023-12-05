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

class ContextStack {
    var _stack: [AnyObject] = []

    func push(_ item: AnyObject) {
        _stack.append(item)
    }

    func pop() -> AnyObject? {
        guard let span = _stack.removeLast() else {
            return nil
        }
        
        return span
    }

    func remove(_ item: AnyObject) {
        _stack.removeAll(where: { item === $0 })
    }

    func last() -> AnyObject? {
        guard let span = _stack.last else {
            return nil
        }

        return span
    }
}

class LinuxActivityContextManager: ContextManager {
    static let instance = LinuxActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [activity_id_t: ContextStack]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let threadId = TaskSupport.instance.getCurrentIdentifier()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard var stack = contextMap[threadId] else {
            print("LinuxActivityContextManager.\(#function): no stack yet for: \(threadId)")
            return nil
        }

        guard var item = stack.last() else {
            print("LinuxActivityContextManager.\(#function): context stack is empty")
            return nil
        }

        print("LinuxActivityContextManager.\(#function): found item: \(item).")

        return item
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let threadId = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[threadId] == nil {
            contextMap[threadId] = ContextStack()
        }

        print("LinuxActivityContextManager.\(#function): remembering span: \(value) for: \(threadId)")

        contextMap[threadId].push(value)

        print("LinuxActivityContextManager.\(#function): \(contextMap)")
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let threadId = TaskSupport.instance.getCurrentIdentifier()

        print("LinuxActivityContextManager.\(#function): remove: \(value); id: \(threadId):")
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard stack = contextMap[threadId] else {
            print("LinuxActivityContextManager.\(#function): no stack for: \(threadId)")
            return
        }

        stack.remove(value)
    }
}

#endif
