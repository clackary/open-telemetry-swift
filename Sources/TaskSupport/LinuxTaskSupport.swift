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
import ucontext

@_silgen_name("_getcontext") private func _getcontext(_ dso: UnsafeRawPointer?, _ buf: UnsafeRawPointer?) -> Int

public class LinuxTaskSupport {
    let parentActivity: parent_activity_id_t = 0  // Linux offers no connectivity to parent contexts
    
    public func getIdentifiers() -> (activity_id_t, parent_activity_id_t) {
        return (getContext(), parentActivity)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return getContext()
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (getContext(), ScopeElement(scope: 0))
    }

    public func leaveScope(scope: ScopeElement) {
        // "scopes" are an os.activity concept; this function is a no-op on Linux
    }

    func getContext() -> activity_id_t {
        let dso = UnsafeMutableRawPointer(mutating: #dsohandle)
        var ucp: ucontext_t = ucontext_t()

        guard getcontext(dso, &ucp) == 0 else {
            print("LinuxTaskSupport.createActivityContext(): failed to get user context!")
            return ucontext(context: ucp)
        }

        return ucontext(context: ucp)
    }
}

#endif
