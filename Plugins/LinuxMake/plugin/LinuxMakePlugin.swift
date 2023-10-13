
// This SPM build plugin is used to run the project Makefile on Linux distributions; required
// due to the need for a C shared library wrapper we've written that allows use of the libc
// getcontext() function.

import Foundation
import PackagePlugin

@main
struct LinuxMakePlugin: BuildToolPlugin {
    static let target = "libpl"
    
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) throws -> [PackagePlugin.Command] {
        return [
          .buildCommand(
            displayName: "Runs Makefile on Linux",
            executable: try context.tool(named: "LinuxMake").path,
            arguments: [context.package.directory, target]
          )
        ]
    }
}
