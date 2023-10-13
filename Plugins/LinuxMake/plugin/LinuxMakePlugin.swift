
// This SPM build plugin is a proof-of-concept used to evaluate how we would write a
// build tool plugin to create a bundle of Swift code for use by our simulators.

import Foundation
import PackagePlugin

@main
struct BundleForSimsPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) throws -> [PackagePlugin.Command] {
        return [
          .buildCommand(
            displayName: "Bundle Simulator Resources",
            executable: try context.tool(named: "BundleForSims").path,
            arguments: [context.package.directory]
          )
        ]
    }
}

// @main
// struct BundleForSimsPlugin: BuildToolPlugin {
//     func createBuildCommands(
//         context: PackagePlugin.PluginContext,
//         target: PackagePlugin.Target
//     ) throws -> [PackagePlugin.Command] {
//         let cmd = "/bin/ls"
//         let output = "/tmp/bundler.log"

//         print(context.package.directory)
        
//         return [
//           .buildCommand(
//             displayName: "Bundle Simulator Resources",
//             executable: try context.tool(named: "BundleForSims").path,
//             arguments: [cmd, "-l", "/tmp/", output]
//           )
//         ]
//     }
// }
