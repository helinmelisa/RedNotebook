import LocalAuthentication

/// Keeps the notebook shut until Face ID (or the passcode) says it's you.
enum AppLock {
    static let enabledKey = "lockWithFaceID"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    /// "Face ID", "Touch ID" or "Passcode", whichever this iPhone uses.
    static var methodName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    /// Asks for Face ID, falling back to the iPhone passcode. True if it's you.
    static func authenticate(reason: String = "Open your notebook") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Keep closed"
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else { return false }
        return (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)) ?? false
    }
}
