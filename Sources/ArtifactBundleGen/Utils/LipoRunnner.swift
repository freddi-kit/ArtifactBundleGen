import Foundation

struct LipoRunnner {
    func checkArch(of targetPath: String) throws -> [String] {
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

        let separatorSet = CharacterSet([" ", "\n"])
        guard let supportedCPUs = output?.components(separatedBy: separatorSet)
            .filter({ $0 != "" })
        else {
            throw ArtifactBundleGenError.lipoEmptyResult
        }
        return supportedCPUs
    }
}
