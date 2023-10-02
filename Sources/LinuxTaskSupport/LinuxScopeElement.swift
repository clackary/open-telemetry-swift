/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

public class LinuxScopeElement: ScopeElement {
    var scope:Int = 0

    init() {
        self.scope = 42
    }
}
