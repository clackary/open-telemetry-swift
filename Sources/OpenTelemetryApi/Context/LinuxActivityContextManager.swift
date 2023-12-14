/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(Linux)

class LinuxActivityContextManager: ContextManager {
    static let instance = LinuxActivityContextManager()

    func setCurrentSpan(span: Span) {

    }

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        return nil
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {

    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {

    }
}

#endif
