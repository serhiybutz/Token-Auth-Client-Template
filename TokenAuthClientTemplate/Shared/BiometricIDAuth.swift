import LocalAuthentication
import OSLog

final class BiometricIDAuth: ObservableObject {
    // MARK: - Properties

    let context = LAContext()
    let reason: String

    @Published private(set) var isAuthSuccessful: Bool?
    @Published private(set) var error: LAError?

    // MARK: - Initialization

    init(reason: String = "Logging in with biometrics") throws {

        self.reason = reason

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        else {
            os_log(.info, log: OSLog.default, "[BiometricIDAuth] Init failed: \(error!.localizedDescription)")
            throw error!
        }
    }

    // MARK: - API

    var biometricType: BiometricType {

        let type = context.biometryType
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .other(type)
        }
    }

    func requestBiometricAuth(handler: ((Bool) -> Void)? = nil) async {
        do {

            self.isAuthSuccessful = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                                     localizedReason: reason)
        } catch {

            self.isAuthSuccessful = false
            let laError = (error as! LAError)
            os_log(.info, log: OSLog.default, "[BiometricIDAuth] Auth failed: \(laError.localizedDescription)")
            self.error = laError
        }

        if let result = self.isAuthSuccessful {
            handler?(result)
        }
    }

    // MARK: - Types

    enum BiometricType: Equatable {
        case none
        case touchID
        case faceID
        case other(LABiometryType)
    }
}
