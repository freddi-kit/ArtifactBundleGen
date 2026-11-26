import Foundation

struct LipoRunnner {
    func checkArch(of targetPath: String) throws -> [String] {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/lipo")
        task.arguments = ["-archs", targetPath]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.standardInput = nil
        do {
            try task.run()
        } catch {
            throw ArtifactBundleGenError.lipoFailure(error: error)
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else {
            throw ArtifactBundleGenError.lipoExitFailure(
                status: task.terminationStatus,
                message: String(data: errorData, encoding: .utf8) ?? ""
            )
        }

        let separatorSet = CharacterSet([" ", "\n"])
        let supportedCPUs = (String(data: outputData, encoding: .utf8) ?? "")
            .components(separatedBy: separatorSet)
            .filter { $0 != "" }
        guard !supportedCPUs.isEmpty else {
            throw ArtifactBundleGenError.lipoEmptyResult
        }
        return supportedCPUs
    }
}
