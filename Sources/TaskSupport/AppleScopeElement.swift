/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import os.activity

public typealias scope_state_s = os_activity_scope_state_s

public protocol ScopeElement {
    func getScopeState() -> scope_state_s
}

public class AppleScopeElement: ScopeElement {
    var scope: scope_state_s

    public func getScopeState() -> scope_state_s {
        return scope
    }
    
    init(scope: scope_state_s) {
        self.scope = scope
    }
}

#endif
