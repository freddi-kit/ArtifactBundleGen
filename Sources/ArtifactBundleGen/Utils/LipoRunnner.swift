import Foundation

class LipoRunnner {
    func chechArch(of targetPath: String) throws -> [String] {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "lipo -archs \(targetPath)"]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        do {
            try task.run()
        } catch {
            throw ArtifactBundleGenError.lipoFailure(error: error)
        }

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)

        let separaterSet = CharacterSet([" ", "\n"])
        guard let supportedCPUs = output?.components(separatedBy: separaterSet)
            .filter({ $0 != "" }) else {
            throw ArtifactBundleGenError.lipoEmptyResult
        }
        return supportedCPUs
    }
}
