enum Error: Swift.Error {
    case timeout

    var code: Int {
        switch self {
        case .timeout:
            return 15
        }
    }
}
