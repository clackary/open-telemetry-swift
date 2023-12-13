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
    var contextManager: ContextManager

    /// Returns the Span from the current context

    public var activeSpan: Span? {
        return contextManager.getCurrentContextValue(forKey: .span) as? Span
    }

    /// Returns the Baggage from the current context

    public var activeBaggage: Baggage? {
        #if os(Linux)
        unsupported(function: #function)
        #endif
        
        return contextManager.getCurrentContextValue(forKey: OpenTelemetryContextKeys.baggage) as? Baggage
    }

    /// Sets the span as the activeSpan for the current context
    /// - Parameter span: the Span to be set to the current context

    public func setActiveSpan(_ span: Span) {
        #if os(Linux)
        contextManager.setCurrentSpan(span: span)
        #else
        contextManager.setCurrentContextValue(forKey: OpenTelemetryContextKeys.span, value: span)
        #endif
    }

    /// Sets the span as the activeSpan for the current context
    /// - Parameter baggage: the Correlation Context to be set to the current contex

    public func setActiveBaggage(_ baggage: Baggage) {
        #if os(Linux)
        unsupported(function: #function)
        #endif
        
        contextManager.setCurrentContextValue(forKey: OpenTelemetryContextKeys.baggage, value: baggage)
    }

    public func removeContextForSpan(_ span: Span) {
        contextManager.removeContextValue(forKey: OpenTelemetryContextKeys.span, value: span)
    }

    public func removeContextForBaggage(_ baggage: Baggage) {
        #if os(Linux)
        unsupported(function: #function)
        #endif
        
        contextManager.removeContextValue(forKey: OpenTelemetryContextKeys.baggage, value: baggage)
    }

    func unsupported(function: String) {
        print("OpenTelementryContextProvider.\(function): Only Spans are supported at this time!")

        abort()
    }
}
