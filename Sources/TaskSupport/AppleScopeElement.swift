/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import os.activity

public protocol ScopeElement {
    var scope: ScopeElement { get }
}

public class AppleScopeElement: ScopeElement {
    var scope: os_activity_scope_state_s

    init(scope: os_activity_scope_state_s) {
        self.scope = scope
    }
}

#endif
