/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import os.activity

// Bridging Obj-C variabled defined as c-macroses. See `activity.h` header.

private let OS_ACTIVITY_CURRENT = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_current"),
                                                to: os_activity_t.self)
@_silgen_name("_os_activity_create") private func _os_activity_create(_ dso: UnsafeRawPointer?,
                                                                      _ description: UnsafePointer<Int8>,
                                                                      _ parent: Unmanaged<AnyObject>?,
                                                                      _ flags: os_activity_flag_t) -> AnyObject!

public class TaskSupport {
    static let instance = TaskSupport()

    class ScopeElement {
        init(scope: os_activity_scope_state_s) {
            self.scope = scope
        }

        var scope: os_activity_scope_state_s
    }

    public func getIdentifiers() -> AnyObject? {
        var parentIdent: os_activity_id_t = 0

        let activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, &parentIdent)

        return (activityIdent, parentIdent)
    }

    public func getCurrentIdentifier() -> AnyObject? {
        return os_activity_get_identifier(OS_ACTIVITY_CURRENT, nil)
    }
    
    public func getScope() -> ScopeElement {
        return ScopeElement(scope: scope)
    }

    func removeTaskSupport() {
        if let scope = objectScope.object(forKey: value) {
            var scope = scope.scope
            
            os_activity_scope_leave(&scope)
            objectScope.removeObject(forKey: value)
        }
    }

    fileprivate func createScope() -> (os_activity_scope_state_s) {
        let dso = UnsafeMutableRawPointer(mutating: #dsohandle)
        let activity = _os_activity_create(dso, "ActivityContext", OS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT)
        let currentActivityId = os_activity_get_identifier(activity, nil)

        var activityState = os_activity_scope_state_s()

        print("createScope(): activityState: \(activityState)")
        print("createScope(): activity: \(activity); currentActivityId: \(currentActivityId); OS_ACTIVITY_CURRENT: \(OS_ACTIVITY_CURRENT)")
        
        os_activity_scope_enter(activity, &activityState)

        return (currentActivityId, activityState)
    }
}

#endif
