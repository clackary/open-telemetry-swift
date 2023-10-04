/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(Linux)

import Foundation

typealias task_identifier_t = UInt64
typealias activity_id_t = UInt64

public class LinuxTaskSupport {
    public func getIdentifiers() -> (task_identifier_t, activity_id_t) {
        return (0, 0)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return 0
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        let activityState = 0

        return (0, ScopeElement(scope: activityState))
    }

    public func leaveScope(scope: ScopeElement) {
        
    }
}

#endif
