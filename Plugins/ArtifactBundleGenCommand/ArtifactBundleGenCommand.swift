import PackagePlugin
import Foundation
import OSLog

@main
struct ArtifactBundleGenCommand: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        var argumentExtractor = ArgumentExtractor(arguments)

        let packageVersionOption = argumentExtractor.extractOption(named: "package-version")
        let executableNameOption = argumentExtractor.extractOption(named: "executable-name")
        let buildFolderNameOption = argumentExtractor.extractOption(named: "build-folder")
        let configOption = argumentExtractor.extractOption(named: "build-config")

        guard let name = executableNameOption.first else {
            throw ArtifactBundleGenError.nameOptionMissing
        }

        guard let configString = configOption.first, let config = Config(rawValue: configString) else {
            throw ArtifactBundleGenError.configOptionParseError(configString: configOption.first ?? "{empty}")
        }

        let artifactBundleGen = ArtifactBundleGen(
            version: packageVersionOption.first ?? "1.0.0",
            name: name,
            buildFolderName: buildFolderNameOption.first ?? ".build",
            config: config
        )
        try await artifactBundleGen.generate()
    }
}
