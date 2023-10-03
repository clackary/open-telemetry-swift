/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

#if os(Linux)

public class LinuxScopeElement: ScopeElement {
    var scope:Int = 0

    init() {
        self.scope = 42
    }
}

#endif
