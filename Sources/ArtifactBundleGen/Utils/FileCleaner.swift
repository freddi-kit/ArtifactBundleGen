import Foundation

class FileCleaner {
    func clean(path: URL) throws {
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            throw ArtifactBundleGenError.cleanFailure(error: error)
        }
    }
}
