// Copyright (c) 2023 PassiveLogic, Inc.

// This file is the logic implementing our BundleForSims plugin. As of this writing (06/06/2023),
// the code here functions properly when dependent applications are built within Xcode. We are
// awaiting further details about how exactly the simulation developers need the generated code
// bundle to be deployed. At present, the plugin creates both .zip and .tar files containing all
// packages found in the Packages directory. This may or may not be the required format; after
// an initial code review, the finishing touches will be applied.

import Foundation

@main
enum LinuxMake {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            throw LinuxMakeError.invalidArguments("LinuxSims: wrong number of arguments: " + String(CommandLine.arguments.count))
        }

        let cwd = CommandLine.arguments[1]
        let target = CommandLine.arguments[2]
        
        debugPrint("LinuxMake: target is: \(target); cwd is: \(cwd)")

        let rval = make(target)
        
        if (rval == 0) {
            debugPrint("LinuxMake: make for \(target) successful")
        } else {
            debugPrint("LinuxMake: make for \(target) failed")
        }
    }

    static func make(_ target: String) -> Int32 {
        let p = Process()

        p.launchPath = "/usr/bin/make"
        p.arguments = target

        p.launch()
        p.waitUntilExit()

        return p.terminationStatus
    }

    static func removePath(path: String) throws {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: path) {
            try fm.removeItem(atPath: path)
        }
    }
}

private enum MakeLinuxError: Error {
    case invalidArguments(String)
    case error(String)
}
