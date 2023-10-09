/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

import os.activity

public typealias activity_id_t = os_activity_id_t
public typealias activity_scope_state_s = os_activity_scope_state_s

#else

import ucontext

// On Linux there is no equivalent of the os.activity library. We've chosen to use pthread
// identifiers to serve as activity IDs, but in Swift concurrency threads do NOT necessarily
// map one-to-one to tasks spawned by async/await constructs; this is an area that is not
// completely understood. There might be issues here.

public typealias activity_id_t = ucontext_t
public typealias activity_scope_state_s = UInt64  // this is an opaque structure on MacOS

#endif

public class TaskSupport {
    #if os(iOS) || os(macOS) || os(tvOS)    
    static public let instance = AppleTaskSupport()
    #else
    static public let instance = LinuxTaskSupport()
    #endif

    public func getIdentifiers() -> (activity_id_t, activity_id_t) {
        return TaskSupport.instance.getIdentifiers()
    }

    public func getCurrentIdentifier() -> activity_id_t {
        return TaskSupport.instance.getCurrentIdentifier()
    }

    public func createActivityContext() -> (activity_id_t, ScopeElement) {
        return TaskSupport.instance.createActivityContext()
    }

    public func leaveScope(scope: ScopeElement) {
        TaskSupport.instance.leaveScope(scope: scope)
    }
}
