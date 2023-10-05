/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class represents what is supposed to be the Linux equivalent of Apple's os.activity library.
// Except that there is no such beast in existence. The best advice I've received thus far was from a very
// experienced MacOS developer, who strongly urged we not attempt to re-create that library for Linux.
// For now, we'll see if libpthread is sufficient. Trouble is, Swift concurrency - async/await (Tasks) -
// can apparently span OS-level threads on occasion, which means pthread_self() will not always be reliable.
// Testing will reveal whether or not this will work for our needs.

#if os(Linux)

import Foundation

import libpthread

typealias task_identifier_t = UInt64
typealias activity_id_t = UInt64

public class LinuxTaskSupport {
    let parentActivity: activity_id_t = 0
    
    public func getIdentifiers() -> (task_identifier_t, activity_id_t) {
        return (pthread_self(), parentActivity)
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return pthread_self()
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return (getCurrentIdentifier(), ScopeElement(scope: defaultActivity))
    }

    public func leaveScope(scope: ScopeElement) {
        // no-op
    }
}

#endif
