import Foundation

public struct ArtifactBundleGen {
    private let version: String
    private let name: String
    private let buildFolderName: String
    private let config: Config
    private let includeResourcePaths: [String]
    private let universalBinaryFolderName: String?

    private let folderCreator = FolderCreator()
    private let lipoRunner = LipoRunnner()
    private let fileCopy = FileCopy()
    private let fileExistChecker = FileExistChecker()
    private let zipComposer = ZipComposer()
    private let fileCleaner = FileCleaner()

    private var artifactBundleFolderName: String {
        "\(name).artifactbundle"
    }

    /// Folders where SwiftPM may place a multi-architecture (`--arch arm64 --arch x86_64`) build.
    /// The location changed in Swift 6.4 from `apple/Products` to `out/Products`.
    private var appleUniversalBinaryFolderCandidates: [String] {
        if let universalBinaryFolderName {
            return [universalBinaryFolderName]
        }
        return [
            "\(buildFolderName)/apple/Products/\(config.headUpperCase)",
            "\(buildFolderName)/out/Products/\(config.headUpperCase)",
        ]
    }

    private func prepareArtifactBundleFolder() throws {
        try folderCreator.createFolder(name: artifactBundleFolderName)
    }

    private func generateAppleUniversalUniversalBinaryArchIfExists(with includeResourcePaths: [String]) throws -> [Variant] {
        guard let appleUniversalBinaryFolderName = appleUniversalBinaryFolderCandidates.first(where: {
            fileExistChecker.isExist(path: "\($0)/\(name)")
        }) else { return [] }
        let appleUniversalBinaryPath = "\(appleUniversalBinaryFolderName)/\(name)"

        var variants: [Variant] = []
        let supportedArchs = try lipoRunner.checkArch(of: appleUniversalBinaryPath)

        let appBundleUniversalBinaryFolderName = "\(name)-\(version)-macosx"
        let destinationUniversalBinaryFolderName = "\(artifactBundleFolderName)/\(appBundleUniversalBinaryFolderName)/bin"
        try folderCreator.createFolder(name: destinationUniversalBinaryFolderName)

        let originExecutableURL = URL(fileURLWithPath: appleUniversalBinaryPath)
        let destinationURL = URL(fileURLWithPath: "\(destinationUniversalBinaryFolderName)/\(name)")

        try fileCopy.copy(from: originExecutableURL, to: destinationURL)
        try includeResourcePaths.forEach {
            let resourceFileURL = URL(fileURLWithPath: $0)
            try fileCopy.copy(
                from: resourceFileURL,
                to: URL(fileURLWithPath: destinationUniversalBinaryFolderName).appendingPathComponent(resourceFileURL.lastPathComponent)
            )
        }

        let bundleNames = try FileManager.default.contentsOfDirectory(atPath: appleUniversalBinaryFolderName)
            .filter { $0.hasSuffix(".bundle") }

        for bundleName in bundleNames {
            try fileCopy.copy(
                from: URL(fileURLWithPath: appleUniversalBinaryFolderName).appendingPathComponent(bundleName),
                to: URL(fileURLWithPath: destinationUniversalBinaryFolderName).appendingPathComponent(bundleName)
            )
        }

        variants.append(
            Variant(
                path: "\(appBundleUniversalBinaryFolderName)/bin/\(name)",
                supportedTriples: supportedArchs.map {
                    "\($0)-apple-macosx"
                }
            )
        )

        return variants
    }

    private func generateEachTriplesVariantsIfExists(with includeResourcePaths: [String]) throws -> [Variant] {
        var variants: [Variant] = []

        // check for all triples
        for triple in VariantTriples.triples {
            let tripleFolderPath = "\(buildFolderName)/\(triple)/\(config.rawValue)"
            let executablePath = "\(tripleFolderPath)/\(name)"
            guard fileExistChecker.isExist(path: executablePath) else { continue }

            let artifactTripleDirectoryPath = "\(artifactBundleFolderName)/\(triple)/bin"
            try folderCreator.createFolder(name: artifactTripleDirectoryPath)

            let originExecutableURL = URL(fileURLWithPath: executablePath)
            let destinationURL = URL(fileURLWithPath: "\(artifactTripleDirectoryPath)/\(name)")

            try fileCopy.copy(from: originExecutableURL, to: destinationURL)
            try includeResourcePaths.forEach {
                let resourceFileURL = URL(fileURLWithPath: $0)
                try fileCopy.copy(
                    from: resourceFileURL,
                    to: URL(fileURLWithPath: artifactTripleDirectoryPath).appendingPathComponent(resourceFileURL.lastPathComponent)
                )
            }

            let bundleNames = try FileManager.default.contentsOfDirectory(atPath: tripleFolderPath)
                .filter { $0.hasSuffix(".bundle") }

            for bundleName in bundleNames {
                try fileCopy.copy(
                    from: URL(fileURLWithPath: tripleFolderPath).appendingPathComponent(bundleName),
                    to: URL(fileURLWithPath: artifactTripleDirectoryPath).appendingPathComponent(bundleName)
                )
            }

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
        let artifact = Artifact(
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

    public init(
        version: String,
        name: String,
        buildFolderName: String,
        config: Config,
        includeResourcePaths: [String],
        universalBinaryFolderName: String? = nil
    ) {
        self.version = version
        self.name = name
        self.buildFolderName = buildFolderName
        self.config = config
        self.includeResourcePaths = includeResourcePaths
        self.universalBinaryFolderName = universalBinaryFolderName
    }

    public func generate() async throws {
        try prepareArtifactBundleFolder()

        var variants: [Variant] = []

        let generatedAppleUniversalUniversalBinaryVariants = try generateAppleUniversalUniversalBinaryArchIfExists(with: includeResourcePaths)
        variants.append(contentsOf: generatedAppleUniversalUniversalBinaryVariants)

        let generatedEachTriplesVariants = try generateEachTriplesVariantsIfExists(with: includeResourcePaths)
        variants.append(contentsOf: generatedEachTriplesVariants)

        guard !variants.isEmpty else {
            try? fileCleaner.clean(path: URL(fileURLWithPath: artifactBundleFolderName))
            throw ArtifactBundleGenError.noExecutableFound(
                name: name,
                searchedPaths: appleUniversalBinaryFolderCandidates + VariantTriples.triples.map { "\(buildFolderName)/\($0)/\(config.rawValue)" }
            )
        }

        let artifactBundle = generateArtifactBundle(variants: variants)
        let destinationPath = URL(fileURLWithPath: "\(artifactBundleFolderName)/info.json")

        try encodeToJsonString(artifactBundle: artifactBundle)
            .write(to: destinationPath, atomically: true, encoding: .utf8)

        let artifactBundleFolderPath = URL(fileURLWithPath: artifactBundleFolderName)

        try await zipComposer.composeBundle(path: artifactBundleFolderPath)
        try fileCleaner.clean(path: artifactBundleFolderPath)
    }
}
