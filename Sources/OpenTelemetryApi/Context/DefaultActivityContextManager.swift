/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the Linux behavior required to employ activity, or thread, contexts as offered by
// Apple's os_activity library. There is not a one-to-one mapping between the platform libraries employed;
// we do the best we can for Linux.

import Foundation

class DefaultActivityContextManager: ContextManager {
    static let instance = DefaultActivityContextManager()

    let rlock = NSRecursiveLock()

    var contextMap = [String: AnyObject]()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        rlock.lock()

        defer {
            rlock.unlock()
        }

        guard let contextValue = contextMap[key.rawValue] else {
            return nil
        }

        return contextValue
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let keyVal = key.rawValue
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if contextMap[keyVal] == nil {
            contextMap[keyVal] = [String: AnyObject]()
        }

        contextMap[keyVal]? = value
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        let keyVal = key.rawValue
        
        rlock.lock()

        defer {
            rlock.unlock()
        }

        if let currentValue = contextMap[keyVal],
           currentValue === value {
            contextMap[keyVal] = nil

            if contextMap[keyVal]?.isEmpty ?? false {
                contextMap[keyVal] = nil
            }
        }
    }
}
