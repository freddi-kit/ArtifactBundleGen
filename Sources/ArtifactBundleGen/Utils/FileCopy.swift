import Foundation

class FileCopy {
    func copy(from origin: URL, to destination: URL) throws {
        do {
            try FileManager.default.copyItem(
                at: origin,
                to: destination
            )
        } catch {
            throw ArtifactBundleGenError.fileCopyFailure(
                origin: origin.absoluteString,
                destination: destination.absoluteString,
                error: error
            )
        }
    }
}
