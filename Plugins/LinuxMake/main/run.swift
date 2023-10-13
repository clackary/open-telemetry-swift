// Copyright (c) 2023 PassiveLogic, Inc.

// This file is the logic implementing our LinuxMake plugin.

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

        let (cmdout, rval) = make(target)
        
        if (rval == 0) {
            debugPrint("LinuxMake: make for \(target) success:")
        } else {
            debugPrint("LinuxMake: make for \(target) failed: exit code: \(rval)")
        }

        debugPrint(cmdout)
    }

    static func make(_ target: String) -> (String?, Int32) {
        let p = Process()
        let pipe = Pipe()

        p.standardOutput = pipe
        p.standardError = pipe
        
        p.launchPath = "/usr/bin/make"
        p.arguments = target

        p.launch()
        p.waitUntilExit()

        let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)

        return (out, p.terminationStatus)
    }

    static func removePath(path: String) throws {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: path) {
            try fm.removeItem(atPath: path)
        }
    }
}

private enum LinuxMakeError: Error {
    case invalidArguments(String)
    case error(String)
}
