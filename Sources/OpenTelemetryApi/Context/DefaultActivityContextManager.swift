/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the Linux behavior required to employ activity, or thread, contexts as offered by
// Apple's os_activity library. There is not a one-to-one mapping between the platform libraries employed;
// we do the best we can for Linux.

#if os(Linux)

import Foundation
import ucontext

import TaskSupport

class UContext: Hashable, Equatable {
    var context: UnsafePointer<ucontext_t>?
    
    static func == (a: UContext, b: UContext) -> Bool {
        return a.context == b.context
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }

    init(context: ucontext_t) {
        self.context = UnsafePointer<ucontext_t>(context)
    }
}

class DefaultActivityContextManager: ContextManager {
    static let instance = DefaultActivityContextManager()

    let rlock = NSRecursiveLock()

    // var contextMap = [UContext: [String: AnyObject]]()
    var contextMap = [ucontext_t, [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, parentIdent) = TaskSupport.instance.getIdentifiers()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let context = contextMap[activityIdent] ?? contextMap[parentIdent] else {
            return nil
        }

        return context[key.rawValue]
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[activityIdent] == nil || contextMap[activityIdent]?[key.rawValue] != nil {
            let (activityIdent, _) = TaskSupport.instance.createActivityContext()

            contextMap[activityIdent] = [String: AnyObject]()
        }

        contextMap[activityIdent]?[key.rawValue] = value
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()
        
        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        if let currentValue = contextMap[activityIdent]?[key.rawValue], currentValue === value {
            contextMap[activityIdent]?[key.rawValue] = nil

            if contextMap[activityIdent]?.isEmpty ?? false {
                contextMap[activityIdent] = nil
            }
        }
    }
}

#endif
