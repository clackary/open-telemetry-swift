/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import os.activity

public class ScopeElement {
    var scope: os_activity_scope_state_s

    public func getScopeState() -> os_activity_scope_state_s {
        return scope
    }

    init(scope: os_activity_scope_state_s) {
        self.scope = scope
    }
}

#else

public typealias os_activity_scope_state_s = UInt64

public class ScopeElement {
    public func getScopeState() -> os_activity_scope_state_s {
        return 0
    }

    init(scope: os_activity_scope_state_s) {

    }
}

#endif
    
