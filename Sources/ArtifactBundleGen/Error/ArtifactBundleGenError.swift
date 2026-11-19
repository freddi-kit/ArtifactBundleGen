import Foundation

enum ArtifactBundleGenError: LocalizedError, CustomStringConvertible {
    case folderCreationFailure(folderName: String, error: Error)
    case fileCopyFailure(origin: String, destination: String, error: Error)

    case lipoFailure(error: Error)
    case lipoExitFailure(status: Int32, message: String)
    case lipoEmptyResult

    case zipFailure(error: Error)
    case zipExitFailure(status: Int32)

    case noExecutableFound(name: String, searchedPaths: [String])

    case cleanFailure(error: Error)

    case nameOptionMissing
    case configOptionParseError(configString: String?)

    var description: String { return errorDescription ?? "Unexpected Error" }

    var errorDescription: String? {
        switch self {
        case let .folderCreationFailure(folderName, error): return "Failed to create folder named \"\(folderName)\" : \(error.localizedDescription)"
        case let .fileCopyFailure(origin, destination, error): return "Failed to copy file from \"\(origin)\" to \"\(destination)\" : \(error.localizedDescription)"
        case let .lipoFailure(error): return "Failed to run lipo: \(error.localizedDescription)"
        case let .lipoExitFailure(status, message): return "lipo failed with exit code \(status): \(message)"
        case .lipoEmptyResult: return "Error, lipo returns empty result"
        case .nameOptionMissing: return "Please specify to name by --executable-name"
        case let .configOptionParseError(configString):
            if let configString {
                return "Failed to parse config specified by --build-config: \(configString)"
            } else {
                return "Failed to parse config specified by --build-config: Please specify release or debug"
            }
        case let .zipFailure(error: error): return "Failed to zip artifact bundle: \(error.localizedDescription)"
        case let .zipExitFailure(status): return "Failed to zip artifact bundle: zip exited with code \(status)"
        case let .noExecutableFound(name, searchedPaths):
            return "Could not find a built executable named \"\(name)\". Build it first, or pass its folder with --universal-binary-folder. Searched:\n" + searchedPaths.map { "  \($0)" }.joined(separator: "\n")
        case let .cleanFailure(error: error): return "Failed to clean artifact bundle: \(error.localizedDescription)"
        }
    }
}
