import AuthenticationServices
import Foundation

@MainActor
@Observable
final class AuthService {
    enum AuthState: Equatable {
        case checking
        case signedIn
        case signedOut
    }

    private let keychain = KeychainService()
    private let userIDKey = "com.yourcompany.tinttrack.appleUserID"

    private(set) var state: AuthState = .checking
    private(set) var userIdentifier: String?
    private(set) var lastErrorMessage: String?

    var isSignedIn: Bool {
        state == .signedIn
    }

    init() {
        userIdentifier = try? keychain.load(userIDKey)
        state = userIdentifier == nil ? .signedOut : .signedIn
        Task {
            await refreshCredentialState()
        }
    }

    func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = credential.user
                storeUserIdentifier(userID)
            } else {
                lastErrorMessage = "Unable to read Apple ID credentials."
            }
        case .failure(let error):
            lastErrorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try keychain.delete(userIDKey)
            userIdentifier = nil
            state = .signedOut
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func refreshCredentialState() async {
        guard let userIdentifier else {
            state = .signedOut
            return
        }

        let credentialState = await credentialState(for: userIdentifier)
        switch credentialState {
        case .authorized:
            state = .signedIn
        case .revoked, .notFound:
            signOut()
        case .transferred:
            state = .signedOut
        @unknown default:
            state = .signedOut
        }
    }

    func clearError() {
        lastErrorMessage = nil
    }

    private func storeUserIdentifier(_ userID: String) {
        do {
            try keychain.save(userID, for: userIDKey)
            userIdentifier = userID
            state = .signedIn
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func credentialState(for userID: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                continuation.resume(returning: state)
            }
        }
    }
}
