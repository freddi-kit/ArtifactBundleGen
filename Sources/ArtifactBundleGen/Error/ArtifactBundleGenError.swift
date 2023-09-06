//
//  ArtifactBundleGenError.swift
//
//
//  Created by JP29872 on 2022/12/07.
//

import Foundation

enum ArtifactBundleGenError: LocalizedError, CustomStringConvertible {
    case folderCreationFailure(folderName: String, error: Error)
    case fileCopyFailure(origin: String, destination: String, error: Error)

    case lipoFailure(error: Error)
    case lipoEmptyResult

    case zipFailure(error: Error)

    case cleanFailure(error: Error)

    case nameOptionMissing
    case configOptionParseError(configString: String?)

    var description: String { return errorDescription ?? "Unexpected Error" }

    var errorDescription: String? {
        switch self {
        case let .folderCreationFailure(folderName, error): return "Failed to create folder named \"\(folderName)\" : \(error.localizedDescription)"
        case let .fileCopyFailure(origin, destination, error): return "Failed to copy file from \"\(origin)\" to \"\(destination)\" : \(error.localizedDescription)"
        case let .lipoFailure(error): return "Failed to run lipo: \(error.localizedDescription)"
        case .lipoEmptyResult: return "Error, lipo returns empty result"
        case .nameOptionMissing: return "Please specify to name by --executable-name"
        case let .configOptionParseError(configString):
            if let configString {
                return "Failed to parse config specified by --build-config: \(configString)"
            } else {
                return "Failed to parse config specified by --build-config: Please specify release or debug"
            }
        case let .zipFailure(error: error): return "Failed to zip artifact bundle: \(error.localizedDescription)"
        case let .cleanFailure(error: error): return "Failed to clean artifact bundle: \(error.localizedDescription)"
        }
    }
}
