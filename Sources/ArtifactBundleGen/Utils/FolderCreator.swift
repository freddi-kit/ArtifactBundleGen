import Foundation

class FolderCreator {
    func createFolder(name: String) throws {
        do {
            try FileManager.default.createDirectory(
                atPath: name,
                withIntermediateDirectories: true
            )
        } catch {
            throw ArtifactBundleGenError.folderCreationFailure(folderName: name, error: error)
        }
    }
}
