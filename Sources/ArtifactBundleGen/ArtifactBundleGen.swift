import Foundation

public struct ArtifactBundleGen {

    private let version: String
    private let name: String
    private let buildFolderName: String
    private let config: Config

    private let folderCreator = FolderCreator()
    private let lipoRunner = LipoRunnner()
    private let fileCopy = FileCopy()
    private let fileExistChecker = FileExistChecker()
    private let zipComposer = ZipComposer()
    private let fileCleaner = FileCleaner()

    private var artifactBundleFolderName: String {
        "\(name).artifactbundle"
    }

    private var appleUniversalBinaryFolderName: String {
        "\(buildFolderName)/apple/Products/\(config.headUpperCase)"
    }

    private var appleUniversalBinaryPath: String {
        "\(appleUniversalBinaryFolderName)/xcodegen"
    }

    private func prepareArtifactBundleFolder() throws {
        try folderCreator.createFolder(name: artifactBundleFolderName)
    }

    private func generateAppleUniversalUniversalBinaryArchIfExists() throws -> [Variant] {
        guard fileExistChecker.isExist(path: appleUniversalBinaryPath) else { return [] }

        var variants: [Variant] = []
        let supoortedArchs = try lipoRunner.chechArch(of: appleUniversalBinaryPath)

        let appBundleUniversalBinaryFolderName = "\(name)-\(version)-macosx"
        let destinationUniversalBinaryFolderName = "\(artifactBundleFolderName)/\(appBundleUniversalBinaryFolderName)/bin"
        try folderCreator.createFolder(name: destinationUniversalBinaryFolderName)

        let destinationUniversalBinaryPath = "\(destinationUniversalBinaryFolderName)/\(name)"
        let originExecutableURL = URL(fileURLWithPath: appleUniversalBinaryPath)
        let destinationURL = URL(fileURLWithPath: destinationUniversalBinaryPath)

        try fileCopy.copy(from: originExecutableURL, to: destinationURL)

        variants.append(
            Variant(
                path: "\(appBundleUniversalBinaryFolderName)/bin/\(name)",
                supportedTriples: supoortedArchs.map {
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
            guard fileExistChecker.isExist(path: executablePath) else { continue }

            let artifactTripleDirectryPath = "\(artifactBundleFolderName)/\(triple)/bin"
            try folderCreator.createFolder(name: artifactTripleDirectryPath)

            let destinationPath = "\(artifactTripleDirectryPath)/\(name)"
            let originExecutableURL = URL(fileURLWithPath: executablePath)
            let destinationURL = URL(fileURLWithPath: destinationPath)

            try fileCopy.copy(from: originExecutableURL, to: destinationURL)

            variants.append(
                Variant(
                    path: "\(triple)/bin/\(name)",
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
            schemaVersion: "1.0",
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

    public func generate() async throws {
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

        let artifactBundleFolderPath = URL(fileURLWithPath: artifactBundleFolderName)

        try await zipComposer.composeBundle(path: artifactBundleFolderPath)
        try fileCleaner.clean(path: artifactBundleFolderPath)
    }
}
