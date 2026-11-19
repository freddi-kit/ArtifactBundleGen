import Foundation

class ZipComposer {
    func composeBundle(path bundlePath: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try Process.run(URL(fileURLWithPath: "/usr/bin/zip"), arguments: ["-FSr", "\(bundlePath.relativePath).zip", "\(bundlePath.relativePath)"]) { process in
                    if process.terminationStatus == 0 {
                        continuation.resume(returning: ())
                    } else {
                        continuation.resume(throwing: ArtifactBundleGenError.zipExitFailure(status: process.terminationStatus))
                    }
                }
            } catch {
                continuation.resume(throwing: ArtifactBundleGenError.zipFailure(error: error))
            }
        }
    }
}
