/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the unnecessary Linux behavior for registering span contexts. Since Linux
// does not offer an equivalent to Apple's os.activity library, and after much research and experimentation,
// the best solution here is... nothing. Do nothing; nada; zilch.

#if os(Linux)

import Foundation

class NoOpActivityContextManager: ContextManager {
    static let instance = NoOpActivityContextManager()

    func getCurrentContextValue(forKey key: OpenTelemetryContextKeys) -> AnyObject? {
        return nil
    }

    func setCurrentContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {

    }

    func removeContextValue(forKey key: OpenTelemetryContextKeys, value: AnyObject) {

    }
}

#endif
