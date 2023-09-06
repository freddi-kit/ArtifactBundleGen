import Foundation

enum VariantTriples {
    enum CPU: String, CaseIterable {
        case x86_64
        case arm64
    }

    enum Vendor: String, CaseIterable {
        case apple
        case unknown
    }

    enum OS: String, CaseIterable {
        case macosx
        case linux_gnu = "linux-gnu"
        case windows
    }

    static var triples: [String] {
        var result: [String] = []
        for cpu in CPU.allCases {
            for vendor in Vendor.allCases {
                for os in OS.allCases {
                    result.append("\(cpu.rawValue)-\(vendor.rawValue)-\(os.rawValue)")
                }
            }
        }
        return result
    }
}
