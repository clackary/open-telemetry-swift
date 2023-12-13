/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

public protocol ContextManager: AnyObject {
    func getCurrentContextValue(forKey: OpenTelemetryContextKeys) -> AnyObject?
    func setCurrentContextValue(forKey: OpenTelemetryContextKeys, value: AnyObject)
    func removeContextValue(forKey: OpenTelemetryContextKeys, value: AnyObject)
}

#if os(Linux)
extension ContextManager {
    func setCurrentSpan(span: Span)
}
#endif
