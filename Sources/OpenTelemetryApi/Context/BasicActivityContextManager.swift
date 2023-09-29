/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

// This class implements the Linux behavior required to employ activity, or thread, contexts as offered by
// Apple's os_activity library. There is not a one-to-one mapping between the platform libraries employed;
// we do the best we can for Linux.

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
