import Foundation

public enum Config: String, RawRepresentable, Encodable {
    case debug
    case release

    var headUpperCase: String {
        switch self {
        case .debug:
            return "Debug"
        case .release:
            return "Release"
        }
    }
}
