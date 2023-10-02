/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

#if os(Linux)
import LinuxTaskSupport
#else
import AppleTaskSupport
#endif

public protocol PlatformTaskSupport {
    func getIdentifiers() -> AnyObject?
    func getCurrentIdentifier() -> AnyObject?
    func removeTaskSupport()
}

public class TaskSupport: PlatformTaskSupport {
    #if os(Linux)
    static let instance = LinuxTaskSupport()
    #else
    static let instance = AppleTaskSupport()
    #endif
}
