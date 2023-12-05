/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class is essentially a no-op on Linux, as there is no equivalent of the Apple os.activity
// library.

#if os(Linux)

import Foundation

import Clibpl

public class LinuxTaskSupport {
    public func getIdentifiers() -> (activity_id_t, parent_activity_id_t) {
        let threadId = getCurrentIdentifier()
        
        return (threadId, 0)  // parent ids on Linux are meaningless, and unavailable
    }

    public func getCurrentIdentifier() -> thread_id_t {
        var threadId: thread_id_t = 0

        pl_get_thread_id(&threadId)
        
        return threadId
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (0, ScopeElement(scope: 0))
    }

    public func leaveScope(scope: ScopeElement) {
        // "scopes" are an os.activity concept; this function is a no-op on Linux
    }
}

#endif
