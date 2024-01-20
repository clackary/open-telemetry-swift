/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(Linux) || os(macOS)

import Foundation

class ActivityContextManager: ContextManager {
    static let instance = ActivityContextManager()

    func setCurrentSpan(span: Span) {
        // op-op
    }

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        return nil
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        // no-op
    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {
        // no-op
    }
}

#endif
