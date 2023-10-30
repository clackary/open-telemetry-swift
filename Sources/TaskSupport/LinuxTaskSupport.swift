/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class pretends to be the Linux equivalent of Apple's os.activity library, but in no way succeeds
// as there are currently no Linux analogs to Apple's library. The best advice we've received thus far was from a very
// experienced MacOS developer. He suggested we NOT attempt to re-create that library for Linux. For now,
// we'll see if the libc context API is sufficient; it might very well not work.

#if os(Linux)

import Foundation

import CLibpl

public class LinuxTaskSupport {
    public func getIdentifiers() -> (activity_id_t, parent_activity_id_t) {
        let (cfp, pfp) = getContext()
        
        return (cfp, pfp)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        let (cfp, _) = getContext()
        
        return cfp
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        let (cfp, _) = getContext()
        
        return (cfp, ScopeElement(scope: 0))
    }

    public func leaveScope(scope: ScopeElement) {
        // "scopes" are an os.activity concept; this function is a no-op on Linux
    }

    func getContext() -> (activity_id_t, activity_id_t) {
        var current: activity_id_t = 0
        var parent: activity_id_t = 0

        guard get_context(&current, &parent) == 0 else {
            print("LinuxTaskSupport.createActivityContext(): failed to retrieve the task context!")
            return (0, 0)
        }

        return (current, parent)
    }
}

#endif
