import PackagePlugin
import Foundation
import OSLog

@main
struct ArtifactBundleGenPluginCommand: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        var argumentExtractor = ArgumentExtractor(arguments)

        let packageVersionOption = argumentExtractor.extractOption(named: "package-version")
        let executableNameOption = argumentExtractor.extractOption(named: "executable-name")
        let buildFolderNameOption = argumentExtractor.extractOption(named: "build-folder")
        let configOption = argumentExtractor.extractOption(named: "build-config")
        let includeResourceOption = argumentExtractor.extractOption(named: "include-resource-path")

        guard let name = executableNameOption.first else {
            throw ArtifactBundleGenError.nameOptionMissing
        }

        guard let configString = configOption.first, let config = Config(rawValue: configString) else {
            throw ArtifactBundleGenError.configOptionParseError(configString: configOption.first)
        }

        let artifactBundleGen = ArtifactBundleGen(
            version: packageVersionOption.first ?? "1.0.0",
            name: name,
            buildFolderName: buildFolderNameOption.first ?? ".build",
            config: config,
            includeResourcePaths: includeResourceOption
        )
        try await artifactBundleGen.generate()
    }
}
