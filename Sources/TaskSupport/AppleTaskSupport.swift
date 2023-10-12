/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import os.activity

// Bridging Obj-C variabled defined as c-macroses. See `activity.h` header.

private let OS_ACTIVITY_CURRENT = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_current"), to: os_activity_t.self)

@_silgen_name("_os_activity_create") private func _os_activity_create(_ dso: UnsafeRawPointer?,
                                                                      _ description: UnsafePointer<Int8>,
                                                                      _ parent: Unmanaged<AnyObject>?,
                                                                      _ flags: os_activity_flag_t) -> AnyObject!

public class AppleTaskSupport {
    public func getIdentifiers() -> (os_activity_id_t, os_activity_id_t) {
        var parentIdent: os_activity_id_t = 0

        let activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, &parentIdent)

        return (activityIdent, parentIdent)
    }

    public func getCurrentIdentifier() -> os_activity_id_t {
        return os_activity_get_identifier(OS_ACTIVITY_CURRENT, nil)
    }

    public func createActivityContext() -> (os_activity_id_t, ScopeElement) {
        let dso = UnsafeMutableRawPointer(mutating: #dsohandle)
        let activity = _os_activity_create(dso, "ActivityContext", OS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT)
        let currentActivityId = os_activity_get_identifier(activity, nil)

        var activityState = os_activity_scope_state_s()

        os_activity_scope_enter(activity, &activityState)

        return (currentActivityId, ScopeElement(scope: activityState))
    }

    public func leaveScope(scope: ScopeElement) {
        var sid: os_activity_scope_state_s = scope.getScopeState()

        os_activity_scope_leave(&sid)
    }
}

#endif
