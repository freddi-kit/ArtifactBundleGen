import Foundation

class FileExistChecker {
    func isExist(path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
}
