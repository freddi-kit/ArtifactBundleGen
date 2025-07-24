import Foundation

class ZipComposer {
    func composeBundle(path bundlePath: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try Process.run(URL(fileURLWithPath: "/usr/bin/zip"), arguments: ["-FSr", "\(bundlePath.relativePath).zip", "\(bundlePath.relativePath)"]) { _ in
                    continuation.resume(returning: ())
                }
            } catch {
                continuation.resume(with: .failure(ArtifactBundleGenError.zipFailure(error: error)))
            }
        }
    }
}
