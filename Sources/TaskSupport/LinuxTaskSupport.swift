/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class represents what is supposed to be the equivalent of Apple's os.activity library. Except
// that there is no such beast in existence. The best advice I've received thus far was from a very
// experienced MacOS developer, who strongly urged we not attempt to re-create that library for Linux.
// Just make this class a giant no-op.

#if os(Linux)

import Foundation

import libpthread

typealias task_identifier_t = UInt64
typealias activity_id_t = UInt64

public class LinuxTaskSupport {
    let defaultActivity: task_identifier_t = 1
    let parentActivity: activity_id_t = 0
    
    public func getIdentifiers() -> (task_identifier_t, activity_id_t) {
        return (defaultActivity, parentActivity)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return defaultActivity
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (defaultActivity, ScopeElement(scope: defaultActivity))
    }

    public func leaveScope(scope: ScopeElement) {
        // no-op
    }
}

#endif
