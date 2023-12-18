/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

/// This class provides a static global accessor for telemetry objects Tracer, Meter
///  and BaggageManager.
///  The telemetry objects are lazy-loaded singletons resolved via ServiceLoader mechanism.

public struct OpenTelemetry {
    public static var version = "v1.20.0"
    
    public static var instance = OpenTelemetry()
    
    init() {
        stableMeterProvider = nil
        tracerProvider = DefaultTracerProvider.instance
        meterProvider = DefaultMeterProvider.instance
        loggerProvider = DefaultLoggerProvider.instance
        baggageManager = DefaultBaggageManager.instance

        // select the context manager
        
        #if os(Linux)
        contextProvider = OpenTelemetryContextProvider()
        #else
        contextProvider = OpenTelemetryContextProvider(contextManager: ActivityContextManager.instance)
        #endif
    }

    /// Registered tracerProvider or default via DefaultTracerProvider.instance.
    public private(set) var tracerProvider: TracerProvider

    /// Registered MeterProvider or default via DefaultMeterProvider.instance.
    public private(set) var meterProvider: MeterProvider

    public private(set) var stableMeterProvider: StableMeterProvider?
    
    /// Registered LoggerProvider or default via DefaultLoggerProvider.instance.
    public private(set) var loggerProvider: LoggerProvider

    /// registered manager or default via  DefaultBaggageManager.instance.
    public private(set) var baggageManager: BaggageManager

    /// registered manager or default via  DefaultBaggageManager.instance.
    public private(set) var propagators: ContextPropagators = DefaultContextPropagators(textPropagators: [W3CTraceContextPropagator()], baggagePropagator: W3CBaggagePropagator())

    /// registered manager or default via  DefaultBaggageManager.instance.
    public private(set) var contextProvider: OpenTelemetryContextProvider

    public static func registerStableMeterProvider(meterProvider: StableMeterProvider) {
        instance.stableMeterProvider = meterProvider
    }
    
    public static func registerTracerProvider(tracerProvider: TracerProvider) {
        instance.tracerProvider = tracerProvider
    }

    public static func registerMeterProvider(meterProvider: MeterProvider) {
        instance.meterProvider = meterProvider
    }

    public static func registerLoggerProvider(loggerProvider: LoggerProvider) {
        instance.loggerProvider = loggerProvider
    }

    public static func registerBaggageManager(baggageManager: BaggageManager) {
        instance.baggageManager = baggageManager
    }

    public static func registerPropagators(textPropagators: [TextMapPropagator], baggagePropagator: TextMapBaggagePropagator) {
        instance.propagators = DefaultContextPropagators(textPropagators: textPropagators, baggagePropagator: baggagePropagator)
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
public extension OpenTelemetry {
    @TaskLocal
    @available(macOS 10.15, *)
    static var activeSpan: Span? = nil
    
    static func registerContextManager(contextManager: ContextManager) {
        instance.contextProvider.contextManager = contextManager
    }

    static func getActiveSpan() -> Span? {
        return instance.contextProvider.activeSpan
    }
}
#endif
    
#if os(Linux)
public extension OpenTelemetry {
    @TaskLocal
    static var activeSpan: Span? = nil
    
    @_unsafeInheritExecutor
    static func withValue<T>(_ value: Span?, operation: () async throws -> T) async rethrows -> T {
        try await OpenTelemetry.$activeSpan.withValue(value, operation: operation)
    }

    static func getActiveSpan() -> Span? {
        return activeSpan
    }
}
#endif
