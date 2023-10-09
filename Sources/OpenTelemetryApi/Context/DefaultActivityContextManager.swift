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

// All this syntactic sugar just so we can use a C ucontext_t struct as a dictionay key.

struct UContext: Hashable, Equatable {
    var context: UnsafeMutableRawPointer
    
    static func == (a: UContext, b: UContext) -> Bool {
        return a.context == b.context
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }

    init(context: ucontext) {
        self.context = Unmanaged.passUnretained(context).toOpaque()
    }
}

class DefaultActivityContextManager: ContextManager {
    static let instance = DefaultActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [UContext: [String: AnyObject]]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()

        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let context = contextMap[UContext(context: activityIdent)] else {
            return nil
        }

        return context[key.rawValue]
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let (activityIdent, _) = TaskSupport.instance.getIdentifiers()
        let contextKey = UContext(context: activityIdent)
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[contextKey] == nil || contextMap[contextKey]?[key.rawValue] != nil {
            let (activityIdent, _) = TaskSupport.instance.createActivityContext()

            contextMap[UContext(context: activityIdent)] = [String: AnyObject]()
        }

        contextMap[contextKey]?[key.rawValue] = value
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let activityIdent = TaskSupport.instance.getCurrentIdentifier()
        let contextKey = UContext(context: activityIdent)
        
        rlock.lock()

        defer {
            rlock.unlock()
        }
        
        if let currentValue = contextMap[contextKey]?[key.rawValue], currentValue === value {
            contextMap[contextKey]?[key.rawValue] = nil

            if contextMap[contextKey]?.isEmpty ?? false {
                contextMap[contextKey] = nil
            }
        }
    }
}

#endif
