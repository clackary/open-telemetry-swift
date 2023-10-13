// Copyright (c) 2023 PassiveLogic, Inc.

// This file is the logic implementing our BundleForSims plugin. As of this writing (06/06/2023),
// the code here functions properly when dependent applications are built within Xcode. We are
// awaiting further details about how exactly the simulation developers need the generated code
// bundle to be deployed. At present, the plugin creates both .zip and .tar files containing all
// packages found in the Packages directory. This may or may not be the required format; after
// an initial code review, the finishing touches will be applied.

import Foundation
import Tarscape
import SWCompression
import ZIPFoundation

@main
enum BundleForSims {
    static let tmpDir = "/private/tmp"

    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            throw BundleForSimsError.invalidArguments("BundleForSims: wrong number of arguments: " + String(CommandLine.arguments.count))
        }

        let pkgdir = CommandLine.arguments[1]
        let tmp = FileManager.default.temporaryDirectory

        let src = URL(fileURLWithPath: pkgdir).appendingPathComponent("Packages")
        let dest = URL(fileURLWithPath: tmp.path).appendingPathComponent("SimRuntimeBundle")
        
        debugPrint("BundleForSims: bundle work directory: \(dest.path)")

        do {
            let bundle = try createBundle(src: src, dest: dest)

            try zipBundle(bundle: bundle)
            try tarBundle(bundle: bundle)
        } catch let e {
            throw BundleForSimsError.bundlerError("BundleFoSims: failed to create bundle at: \(dest.path): \(e.localizedDescription)")
        }
        
        debugPrint("BundleForSims: copied \(src.path) to \(dest.path)")
    }

    static func tarBundle(bundle: Bundle) throws {
        let fm = FileManager.default

        let src = bundle.bundleURL
        let dest = URL(fileURLWithPath: tmpDir).appendingPathComponent("SimRuntimeBundle.tar")

        try removePath(path: dest.path)
        
        do {
            try fm.createTar(at: dest, from: src)
            try gzip(archive: dest)
        } catch let e {
            throw BundleForSimsError.archiveError("BundleForSims: failed to create tgz archive: \(dest.path): \(e.localizedDescription)")
        }
    }

    static func gzip(archive: URL) throws {
        var archivePath = URL(fileURLWithPath: archive.path)  // a working copy of archive

        archivePath.deletePathExtension()
        
        let tgz = archivePath.appendingPathExtension("tgz")
        let tardata = try Data(contentsOf: archive)

        do {
            let gzipData = try GzipArchive.archive(data: tardata)  // this is binary data, in gzip format, as a Data instance

            try gzipData.write(to: tgz)
        } catch let e {
            throw BundleForSimsError.gzipError("BundleForSims: failed to compress archive: \(tgz.path): \(e.localizedDescription)")
        }
    }
    
    static func zipBundle(bundle: Bundle) throws {
        let fm = FileManager()

        let src = bundle.bundleURL
        let dest = URL(fileURLWithPath: tmpDir).appendingPathComponent("SimRuntimeBundle.zip")

        try removePath(path: dest.path)
        
        do {
            try fm.zipItem(at: src, to: dest, shouldKeepParent: false, compressionMethod: .deflate)
        } catch let e {
            throw BundleForSimsError.archiveError("BundleForSims: failed to create zip archive: \(dest.path): \(e.localizedDescription)")
        }
    }
    
    static func createBundle(src: URL, dest: URL) throws -> Bundle {
        let fm = FileManager.default

        try removePath(path: dest.path)
        
        try fm.copyItem(at: src, to: dest)

        guard let bundle = Bundle.init(path: dest.path) else {
            throw BundleForSimsError.bundlerError("BundleForSims: failed to create bundle at: \(dest.path)")
        }

        return bundle
    }

    static func removePath(path: String) throws {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: path) {
            try fm.removeItem(atPath: path)
        }
    }
}

private enum BundleForSimsError: Error {
    case invalidArguments(String)
    case error(String)
    case bundlerError(String)
    case archiveError(String)
    case gitError(String)
    case gzipError(String)
}
