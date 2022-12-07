import Foundation

public struct ArtifactBundleGen {

    private let version: String
    private let name: String
    private let buildFolderName: String
    private let config: Config

    private var artifactBundleFolderName: String {
        "\(name)-\(version)-artifact-bundle"
    }

    private var appleUniversalBinaryFolderName: String {
        "\(buildFolderName)/apple/Products/\(config.headUpperCase)"
    }

    private var appleUniversalBinaryPath: String {
        "\(appleUniversalBinaryFolderName)/xcodegen"
    }

    private func prepareArtifactBundleFolder() throws {
        try FileManager.default.createDirectory(
            atPath: artifactBundleFolderName,
            withIntermediateDirectories: false
        )
    }

    private func generateAppleUniversalUniversalBinaryArchIfExists() throws -> [Variant] {
        guard FileManager.default.fileExists(atPath: appleUniversalBinaryPath) else { return [] }

        var variants: [Variant] = []
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "lipo -archs \(appleUniversalBinaryPath)"]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        try task.run()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)

        let separaterSet = CharacterSet([" ", "\n"])
        let supportedCPUs = output!.components(separatedBy: separaterSet)
            .filter { $0 != "" }

        let destinationUniversalBinaryFolderName = "\(artifactBundleFolderName)/\(Constants.appBundleUniversalBinaryFolderName)"
        try FileManager.default.createDirectory(
            atPath: destinationUniversalBinaryFolderName,
            withIntermediateDirectories: false
        )

        let destinationUniversalBinaryPath = "\(destinationUniversalBinaryFolderName)/\(name)"
        let originExecutableURL = URL(fileURLWithPath: appleUniversalBinaryPath)
        let distinationURL = URL(fileURLWithPath: destinationUniversalBinaryPath)

        try FileManager.default.copyItem(
            at: originExecutableURL,
            to: distinationURL
        )

        variants.append(
            Variant(
                path: "\(Constants.appBundleUniversalBinaryFolderName)/\(name)",
                supportedTriples: supportedCPUs.map {
                    "\($0)-apple-macosx"
                }
            )
        )

        return variants
    }

    private func generateEachTriplesVariantsIfExists() throws -> [Variant] {
        var variants: [Variant] = []

        // check for all triples
        for triple in VariantTriples.triples {
            let executablePath = "\(buildFolderName)/\(triple)/\(config.rawValue)/\(name)"
            guard FileManager.default.fileExists(atPath: executablePath) else { continue }

            let artifactTripleDirectryPath = "\(artifactBundleFolderName)/\(triple)"
            try FileManager.default.createDirectory(
                atPath: "\(artifactBundleFolderName)/\(triple)",
                withIntermediateDirectories: false
            )

            let destinationPath = "\(artifactTripleDirectryPath)/\(name)"
            let originExecutableURL = URL(fileURLWithPath: executablePath)
            let distinationURL = URL(fileURLWithPath: destinationPath)

            try FileManager.default.copyItem(
                at: originExecutableURL,
                to: distinationURL
            )

            variants.append(
                Variant(
                    path: "\(triple)/\(name)",
                    supportedTriples: [triple]
                )
            )
        }

        return variants
    }

    private func generateArtifactBundle(variants: [Variant]) -> ArtifactBundle {
        let artifact =  Artifact(
            version: version,
            type: .executable,
            variants: variants
        )

        return ArtifactBundle(
            schemaVersion: "1.0.0",
            artifacts: [name: artifact]
        )
    }

    private func encodeToJsonString(artifactBundle: ArtifactBundle) throws -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let jsonData = try jsonEncoder.encode(artifactBundle)

        guard let string = String(data: jsonData, encoding: .utf8) else {
            fatalError()
        }
        return string.replacingOccurrences(of: "\\", with: "")
    }

    public init(version: String, name: String, buildFolderName: String, config: Config) {
        self.version = version
        self.name = name
        self.buildFolderName = buildFolderName
        self.config = config
    }

    public func generate() throws {

        try prepareArtifactBundleFolder()

        var variants: [Variant] = []

        let generatedAppleUniversalUniversalBinaryVariants = try generateAppleUniversalUniversalBinaryArchIfExists()
        variants.append(contentsOf: generatedAppleUniversalUniversalBinaryVariants)

        let generatedEachTriplesVariants = try generateEachTriplesVariantsIfExists()
        variants.append(contentsOf: generatedEachTriplesVariants)

        let artifactBundle = generateArtifactBundle(variants: variants)
        let destinationPath = URL(fileURLWithPath: "\(artifactBundleFolderName)/info.json")

        try encodeToJsonString(artifactBundle: artifactBundle)
            .write(to: destinationPath, atomically: true, encoding: .utf8)
    }
}
