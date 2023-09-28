/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

class BasicActivityContextManager: ContextManager {
    static let instance = BasicActivityContextManager()

    func getCurrentContextValue(forKey: OpenTelemetryContextKeys) -> AnyObject? {
        return nil
    }

    func setCurrentContextValue(forKey: OpenTelemetryContextKeys, value: AnyObject) {

    }

    func removeContextValue(forKey: OpenTelemetryContextKeys, value: AnyObject) {

    }
}
