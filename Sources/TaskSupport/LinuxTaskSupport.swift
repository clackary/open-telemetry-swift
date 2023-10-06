/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class pretends to be the Linux equivalent of Apple's os.activity library. Except that there
// is no such beast in existence. The best advice we've received thus far was from a very
// experienced MacOS developer. He suggested we NOT attempt to re-create that library for Linux. For now,
// we'll see if libpthread is sufficient. Trouble is, Swift concurrency - async/await (Tasks) - can apparently span
// OS-level threads on occasion, which means pthread_self() will not always be reliable. Note, however, that other
// areas of opentelemetry-swift employ the pthread interface, so dunno. Testing will reveal whether or not this
// will work for our needs.

#if os(Linux)

import Foundation

public class LinuxTaskSupport {
    // Linux pthreads have no reference to their parent, so there's not much else we can do here
    
    let parentActivity: activity_id_t = 0
    
    public func getIdentifiers() -> (activity_id_t, activity_id_t) {
        return (pthread_self(), parentActivity)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return pthread_self()
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (getCurrentIdentifier(), ScopeElement(scope: 0))
    }

    public func leaveScope(scope: ScopeElement) {
        // "scopes" are an os.activity concept; this function is a no-op on Linux
    }
}

#endif
