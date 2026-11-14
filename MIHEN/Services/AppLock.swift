import LocalAuthentication

@MainActor enum AppLock {
    static func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        // Device passcode is a fallback when biometrics are unavailable or locked out.
        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}
