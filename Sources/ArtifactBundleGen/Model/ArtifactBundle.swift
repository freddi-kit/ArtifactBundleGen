struct Variant: Encodable {
    var path: String
    var supportedTriples: [String]
}

struct Artifact: Encodable {
    enum `Type`: String, Encodable {
        case executable
    }

    var version: String
    var type: `Type`
    var variants: [Variant]
}

struct ArtifactBundle: Encodable {
    var schemaVersion: String
    var artifacts: [String: Artifact]
}
