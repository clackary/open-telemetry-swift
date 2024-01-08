/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class is essentially a no-op on Linux, as there is no equivalent of the Apple os.activity
// library.

#if os(Linux)

import Foundation

public class LinuxTaskSupport {
    public func getIdentifiers() -> (activity_id_t, parent_activity_id_t) {
        return (0, 0)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return 0
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (0, ScopeElement(scope: 0))
    }

    public func leaveScope(scope: ScopeElement) {
        // "scopes" are an os.activity concept; this function is a no-op on Linux
    }
}

#endif
