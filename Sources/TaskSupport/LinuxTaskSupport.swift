/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class pretends to be the Linux equivalent of Apple's os.activity library, but in no way succeeds
// as there are currently no Linux analogs to Apple's library. The best advice we've received thus far was from a very
// experienced MacOS developer. He suggested we NOT attempt to re-create that library for Linux. For now,
// we'll see if libpthread is sufficient. Trouble is, Swift concurrency - async/await (Tasks) - can apparently span
// OS-level threads on occasion, which means pthread_self() will not always be reliable. Note, however, that other
// areas of opentelemetry-swift employ the pthread interface, so dunno. Testing will reveal whether or not this
// will work for our needs.

#if os(Linux)

import Foundation

public typealias activity_id_t = ucontext_t

public class LinuxTaskSupport {
    let parentActivity: activity_id_t = nil  // Linux offers no connectivity to parent contexts
    
    public func getIdentifiers() -> (activity_id_t, activity_id_t) {
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
        var ucp = nil

        guard let rval = getcontext(&ucp) == 0 else {
            print("LinuxTaskSupport.createActivityContext(): failed to get user context!")
            
            return nil
        }

        return ucp
    }
}

#endif
