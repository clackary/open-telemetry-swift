/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

#if os(Linux)
import LinuxTaskSupport
import LinuxScopeElement
#else
import AppleTaskSupport
import AppleScopeElement
#endif

protocol PlatformTaskSupport {
    func getIdentifiers() -> AnyObject?
    func getCurrentIdentifier() -> AnyObject?
    func getScopeElement() -> ScopeElement
    func removeTaskSupport()
}

public class TaskSupport: PlatformTaskSupport {
    #if os(Linux)
    static let instance = LinuxTaskSupport()
    static let scope = LinuxScopeElement()
    #else
    static let instance = AppleTaskSupport()
    static let scope = AppleScopeElement()
    #endif
}
