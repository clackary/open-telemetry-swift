/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

// Keys used by Opentelemetry to store values in the Context

public enum OpenTelemetryContextKeys: String {
    case span
    case baggage
}

public struct OpenTelemetryContextProvider {
    public var activeBaggage: Baggage?
    
    public func setActiveSpan(_ span: Span) {
        // no-op
    }

    public func setActiveBaggage(_ baggage: Baggage) {
        // no-op
    }

    public func removeContextForSpan(_ span: Span) {
        // no-op
    }

    public func removeContextForBaggage(_ baggage: Baggage) {
        // no-op
    }
}
