/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

import os.activity

public typealias activity_id_t = os_activity_id_t
public typealias parent_activity_id_t = os_activity_id_t
public typealias activity_scope_state_s = os_activity_scope_state_s

#else

import CLibpl

// On Linux there is no equivalent of the os.activity library. We've chosen to use the POSIX
// ucontext API to serve as an analog, but as of this writing it's uncertain whether or not
// this will be sufficient.

public class ucontext: Hashable, Equatable {
    var context: ucontext_t

    static public func == (a: ucontext, b: ucontext) -> Bool {
        let size = MemoryLayout<ucontext_t>.size
        
        let rval = withUnsafePointer(to: a.context) { aa in
            withUnsafePointer(to: b.context) { bb in
                return memcmp(aa, bb, size) == 0
            }
        }

        return rval
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }

    public init(context: ucontext_t) {
        self.context = context
    }
}

public typealias activity_id_t = ucontext
public typealias parent_activity_id_t = UInt64  // there's no way to obtain a context parent on Linux
public typealias activity_scope_state_s = UInt64  // this is an opaque structure on MacOS

#endif

public class TaskSupport {
    #if os(iOS) || os(macOS) || os(tvOS)    
    static public let instance = AppleTaskSupport()
    #else
    static public let instance = LinuxTaskSupport()
    #endif

    public func getIdentifiers() -> (activity_id_t, parent_activity_id_t) {
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
