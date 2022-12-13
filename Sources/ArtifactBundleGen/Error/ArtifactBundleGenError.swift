//
//  File.swift
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
    case configOptionParseError(configString: String)

    var description: String { return errorDescription ?? "Unexpected Error" }

    var errorDescription: String? {
        switch self {
        case .folderCreationFailure(let folderName, let error): return "Failed to create folder named \"\(folderName)\" : \(error.localizedDescription)"
        case .fileCopyFailure(let origin, let destination, let error): return "Failed to copy file from \"\(origin)\" to \"\(destination)\" : \(error.localizedDescription)"
        case .lipoFailure(let error): return "Failed to run lipo: \(error.localizedDescription)"
        case .lipoEmptyResult: return "Error, lipo returns empty result"
        case .nameOptionMissing: return "Please specify to name by --package-name"
        case .configOptionParseError(let configString): return "Failed to parse config specified by --build-config: \(configString)"
        case .zipFailure(error: let error): return "Failed to zip artifact bundle: \(error.localizedDescription)"
        case .cleanFailure(error: let error): return "Failed to clean artifact bundle: \(error.localizedDescription)"
        }
    }
}
